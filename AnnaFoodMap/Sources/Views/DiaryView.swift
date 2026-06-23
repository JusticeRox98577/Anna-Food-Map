import SwiftUI
import SwiftData
import Foundation
import Charts

struct DiaryView: View {
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]
    @Query private var reintroTests: [ReintroTest]
    @Environment(\.modelContext) private var modelContext
    @State private var showingForm = false

    @AppStorage("fodmap.reminderEnabled") private var reminderEnabled = false
    @AppStorage("fodmap.reminderHour") private var reminderHour = 19
    @AppStorage("fodmap.reminderMinute") private var reminderMinute = 0

    private var streak: Int {
        let days = Set(entries.map { $0.day })
        var count = 0
        var cursor = Calendar.current.startOfDay(for: Date())
        while days.contains(cursor) {
            count += 1
            cursor = Calendar.current.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return count
    }

    private var flareDays: Int {
        Set(entries.filter { $0.severity == .severe }.map { $0.day }).count
    }

    private var insightText: String? {
        var wordCounts: [String: Int] = [:]
        for entry in entries where entry.type == .meal && entry.severity != .none {
            let words = entry.title.lowercased().split(whereSeparator: { !$0.isLetter })
            for word in words where word.count > 3 {
                wordCounts[String(word), default: 0] += 1
            }
        }
        guard let top = wordCounts.max(by: { $0.value < $1.value }), top.value >= 2 else { return nil }
        return "Pattern detected: \"\(top.key)\" appears in \(top.value) meals logged alongside symptoms. Consider testing this carefully."
    }

    private var groupedByDay: [(day: Date, entries: [DiaryEntry])] {
        let groups = Dictionary(grouping: entries, by: { $0.day })
        return groups.keys.sorted(by: >).map { day in (day, groups[day]!.sorted { $0.date > $1.date }) }
    }

    private var trendData: [(day: Date, severity: Severity)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cutoff = calendar.date(byAdding: .day, value: -13, to: today) ?? today
        let recent = entries.filter { $0.day >= cutoff }
        let grouped = Dictionary(grouping: recent, by: { $0.day })
        let days = grouped.keys.sorted()
        return days.map { day in
            let maxSeverity = grouped[day]?.map { $0.severity.rawValue }.max() ?? 0
            return (day, Severity(rawValue: maxSeverity) ?? .none)
        }
    }

    private var exportURL: URL? {
        ExportManager.writeReportToTemporaryFile(entries: entries, reintroTests: reintroTests)
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 19
                reminderMinute = components.minute ?? 0
                if reminderEnabled {
                    NotificationManager.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PageHeader(title: "Symptom & Food Diary")
                statRow
                if let insight = insightText {
                    insightCard(insight)
                }
                if !trendData.isEmpty {
                    trendChartCard
                }
                reminderCard
                addButton

                if entries.isEmpty {
                    EmptyStateView(symbolName: "book.closed", message: "No entries yet. Start logging your meals and symptoms.")
                } else {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(groupedByDay, id: \.day) { group in
                            Text(dayLabel(group.day).uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.ink500)
                                .padding(.top, 6)

                            ForEach(group.entries) { entry in
                                DiaryEntryRow(entry: entry) {
                                    modelContext.delete(entry)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Diary")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if entries.isEmpty && reintroTests.isEmpty {
                    EmptyView()
                } else if let exportURL {
                    ShareLink(item: exportURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingForm) {
            DiaryEntryForm()
        }
    }

    private var trendChartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Symptom Trend (14 Days)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.ink700)

            Chart(trendData, id: \.day) { point in
                BarMark(
                    x: .value("Day", point.day, unit: .day),
                    y: .value("Severity", point.severity.rawValue)
                )
                .foregroundStyle(severityColor(point.severity))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...2)
            .chartYAxis {
                AxisMarks(values: [0, 1, 2]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let raw = value.as(Int.self), let severity = Severity(rawValue: raw) {
                            Text(severity.emoji)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 140)
        }
        .padding(14)
        .cardStyle()
    }

    private func severityColor(_ severity: Severity) -> Color {
        switch severity {
        case .none: return Theme.green500
        case .mild: return Theme.amber400
        case .severe: return Theme.red400
        }
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $reminderEnabled) {
                Label("Daily log reminder", systemImage: "bell.fill")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Theme.ink700)
            }
            .tint(Theme.green600)
            .onChange(of: reminderEnabled) { _, newValue in
                if newValue {
                    Task {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        if granted {
                            NotificationManager.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                        } else {
                            reminderEnabled = false
                        }
                    }
                } else {
                    NotificationManager.shared.cancelDailyReminder()
                }
            }

            if reminderEnabled {
                DatePicker("Reminder time", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.ink700)
            }
        }
        .padding(14)
        .cardStyle()
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            StatBox(value: "\(entries.count)", label: "Entries")
            StatBox(value: "\(streak)", label: "Day Streak")
            StatBox(value: "\(flareDays)", label: "Flare Days")
        }
    }

    private func insightCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill").foregroundStyle(Theme.amber600)
            Text(text)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.ink700)
        }
        .padding(14)
        .background(Theme.green50)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.green100, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var addButton: some View {
        Button {
            showingForm = true
        } label: {
            Label("Log a meal or symptom", systemImage: "plus")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.green600)
    }

    private func dayLabel(_ day: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        if Calendar.current.isDate(day, inSameDayAs: today) { return "Today" }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today), Calendar.current.isDate(day, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: day)
    }
}

struct StatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 20, weight: .heavy)).foregroundStyle(Theme.green700)
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.ink500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .cardStyle()
    }
}

struct DiaryEntryRow: View {
    let entry: DiaryEntry
    let onDelete: () -> Void

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(timeLabel) · \(entry.type == .meal ? "Meal" : "Symptom")")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.ink500)
                    Text(entry.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.ink900)
                }
                Spacer()
                Text("\(entry.severity.emoji) \(entry.severity.label)")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(severityBackground)
                    .foregroundStyle(severityForeground)
                    .clipShape(Capsule())
            }
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink700)
            }
        }
        .padding(14)
        .padding(.trailing, 22)
        .cardStyle()
        .overlay(alignment: .topTrailing) {
            DeleteCornerButton(action: onDelete)
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var severityBackground: Color {
        switch entry.severity {
        case .none: return Theme.green100
        case .mild: return Theme.amber100
        case .severe: return Theme.red100
        }
    }

    private var severityForeground: Color {
        switch entry.severity {
        case .none: return Theme.green700
        case .mild: return Theme.amber600
        case .severe: return Theme.red600
        }
    }
}

struct DeleteCornerButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.system(size: 12))
                .foregroundStyle(Theme.ink300)
                .padding(8)
        }
        .buttonStyle(.plain)
    }
}

struct DiaryEntryForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var type: EntryType = .meal
    @State private var date: Date = Date()
    @State private var title: String = ""
    @State private var severity: Severity = .none
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(EntryType.allCases) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    DatePicker("Date & time", selection: $date)
                    TextField(type == .meal ? "What did you eat?" : "Symptom summary", text: $title)
                }

                Section("Symptom severity") {
                    Picker("Severity", selection: $severity) {
                        ForEach(Severity.allCases) { s in
                            Text("\(s.emoji) \(s.label)").tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Log Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .readableNavigationBar()
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }

    private func save() {
        let entry = DiaryEntry(
            type: type,
            date: date,
            title: title.trimmingCharacters(in: .whitespaces),
            severity: severity,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(entry)
        dismiss()
    }
}
