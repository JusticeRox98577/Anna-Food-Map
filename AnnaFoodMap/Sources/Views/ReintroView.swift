import SwiftUI
import SwiftData
import Foundation

struct ReintroView: View {
    @Query(sort: \ReintroTest.date, order: .reverse) private var tests: [ReintroTest]
    @Environment(\.modelContext) private var modelContext
    @State private var showingForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statRow
                addButton

                if tests.isEmpty {
                    EmptyStateView(symbolName: "testtube.2", message: "No challenges logged yet.")
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(tests) { test in
                            ReintroTestRow(test: test) {
                                modelContext.delete(test)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Reintroduction Challenges")
        .sheet(isPresented: $showingForm) {
            ReintroForm()
        }
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            StatBox(value: "\(tests.count)", label: "Tested")
            StatBox(value: "\(tests.filter { $0.result == .pass }.count)", label: "Tolerated")
            StatBox(value: "\(tests.filter { $0.result == .fail }.count)", label: "Triggered")
        }
    }

    private var addButton: some View {
        Button {
            showingForm = true
        } label: {
            Label("Log a new challenge", systemImage: "plus")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.green600)
    }
}

struct ReintroTestRow: View {
    let test: ReintroTest
    let onDelete: () -> Void

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: test.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(test.food)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.ink900)
                    Text("\(test.group.rawValue) · \(dateLabel)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.ink500)
                }
                Spacer()
                Text(test.result.label)
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusBackground)
                    .foregroundStyle(statusForeground)
                    .clipShape(Capsule())
            }
            if !test.notes.isEmpty {
                Text(test.notes)
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

    private var statusBackground: Color {
        switch test.result {
        case .pass: return Theme.green100
        case .fail: return Theme.red100
        case .pending: return Theme.amber100
        }
    }

    private var statusForeground: Color {
        switch test.result {
        case .pass: return Theme.green700
        case .fail: return Theme.red600
        case .pending: return Theme.amber600
        }
    }
}

struct ReintroForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var group: ReintroGroup = .fructans
    @State private var food: String = ""
    @State private var date: Date = Date()
    @State private var result: ReintroResult = .pending
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("FODMAP group", selection: $group) {
                        ForEach(ReintroGroup.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    TextField("Food tested", text: $food)
                    DatePicker("Date started", selection: $date, displayedComponents: .date)
                    Picker("Result", selection: $result) {
                        ForEach(ReintroResult.allCases) { r in
                            Text(r.label).tag(r)
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Log Challenge")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(food.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .readableNavigationBar()
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 460)
        #endif
    }

    private func save() {
        let test = ReintroTest(
            group: group,
            food: food.trimmingCharacters(in: .whitespaces),
            date: date,
            result: result,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(test)
        dismiss()
    }
}
