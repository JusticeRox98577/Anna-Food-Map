import Foundation

enum ExportManager {
    static func makeReport(entries: [DiaryEntry], reintroTests: [ReintroTest]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"

        var lines: [String] = []
        lines.append("FODMAP Diary Report")
        lines.append("Generated: \(dateFormatter.string(from: Date()))")
        lines.append("")
        lines.append("=== Diary Entries ===")
        lines.append("Date/Time,Type,Title,Severity,Notes")

        let sortedEntries = entries.sorted { $0.date < $1.date }
        for entry in sortedEntries {
            let type = entry.type == .meal ? "Meal" : "Symptom"
            lines.append(csvRow([
                dateFormatter.string(from: entry.date),
                type,
                entry.title,
                entry.severity.label,
                entry.notes
            ]))
        }

        lines.append("")
        lines.append("=== Reintroduction Tests ===")
        lines.append("Date,Group,Food,Result,Notes")

        let sortedTests = reintroTests.sorted { $0.date < $1.date }
        for test in sortedTests {
            lines.append(csvRow([
                dateFormatter.string(from: test.date),
                test.group.rawValue,
                test.food,
                test.result.label,
                test.notes
            ]))
        }

        return lines.joined(separator: "\n")
    }

    static func writeReportToTemporaryFile(entries: [DiaryEntry], reintroTests: [ReintroTest]) -> URL? {
        let report = makeReport(entries: entries, reintroTests: reintroTests)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = "FODMAP-Diary-\(formatter.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try report.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func csvRow(_ fields: [String]) -> String {
        fields.map { field -> String in
            if field.contains(",") || field.contains("\"") || field.contains("\n") {
                return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
            }
            return field
        }.joined(separator: ",")
    }
}
