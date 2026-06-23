import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Turns a person's casual, free-text food craving into a concise restaurant
/// search query using Apple's on-device Foundation Models (Apple Intelligence).
///
/// This runs entirely on-device — nothing is sent to a server. If Apple
/// Intelligence isn't available (older OS, unsupported hardware, or the model
/// isn't ready), we fall back to using the user's text verbatim so search
/// still works everywhere.
enum FoodQueryInterpreter {
    /// Whether on-device Apple Intelligence is ready to interpret queries.
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability {
                return true
            }
        }
        #endif
        return false
    }

    private static let instructions = """
    You convert a person's casual description of food they want to eat into a \
    short restaurant search query for a maps search. Output only the cuisine or \
    food-type keywords — no punctuation, no explanation, no full sentences. \
    For example, "something with raw fish" becomes "sushi", and "I'm craving a \
    juicy burger" becomes "burgers".
    """

    /// Returns a cleaned-up search term. Falls back to `query` unchanged if the
    /// on-device model is unavailable or returns nothing usable.
    static func interpret(_ query: String) async -> String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability {
                let session = LanguageModelSession(instructions: instructions)
                if let response = try? await session.respond(to: trimmed) {
                    let interpreted = response.content
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !interpreted.isEmpty {
                        return interpreted
                    }
                }
            }
        }
        #endif

        return trimmed
    }
}
