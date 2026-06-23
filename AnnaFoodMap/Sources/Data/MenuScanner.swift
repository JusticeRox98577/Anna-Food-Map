import Foundation

struct MenuMatch: Identifiable {
    var id: String { food.name }
    let food: Food
}

struct MenuScanResult {
    let matches: [MenuMatch]
    let triggerWords: [String]
}

/// Best-effort scan of a restaurant's website for mentions of known foods and
/// common high-FODMAP trigger words. Many restaurant sites render their menu
/// via JavaScript or as images/PDFs, in which case this will find nothing —
/// that's an inherent limit of scraping raw HTML rather than using a menu API.
enum MenuScanner {
    private static let highFODMAPTriggerWords = [
        "garlic", "onion", "wheat", "gluten", "honey", "mushroom", "cauliflower", "chickpea", "lentil"
    ]

    static func scan(url: URL) async -> MenuScanResult? {
        var request = URLRequest(url: url)
        request.timeoutInterval = 8

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            return nil
        }

        let text = strippedText(from: html).lowercased()

        let matches = FoodDatabase.all
            .filter { text.contains($0.name.lowercased()) }
            .map { MenuMatch(food: $0) }

        let triggerWords = highFODMAPTriggerWords.filter { text.contains($0) }

        return MenuScanResult(matches: matches, triggerWords: triggerWords)
    }

    private static func strippedText(from html: String) -> String {
        var result = ""
        result.reserveCapacity(html.count)
        var insideTag = false
        for char in html {
            if char == "<" {
                insideTag = true
            } else if char == ">" {
                insideTag = false
                result.append(" ")
            } else if !insideTag {
                result.append(char)
            }
        }
        return result
    }
}
