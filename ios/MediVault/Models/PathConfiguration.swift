import Foundation

// MARK: - Path Configuration

class PathConfiguration {
    static let shared = PathConfiguration()

    private var rules: [Rule] = []

    struct Rule: Codable {
        let patterns: [String]
        let properties: PathProperties
    }

    struct PathProperties: Codable {
        let context: String
        let pullToRefreshEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case context
            case pullToRefreshEnabled = "pull_to_refresh_enabled"
        }

        var presentation: Presentation {
            return context == "modal" ? .modal : .default
        }
    }

    enum Presentation {
        case `default`
        case modal
    }

    private init() {}

    // MARK: - Loading

    func load() {
        guard let url = Bundle.main.url(forResource: "configuration", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(Configuration.self, from: data) else {
            print("Failed to load path configuration")
            return
        }

        rules = config.rules
        print("Loaded \(rules.count) path configuration rules")
    }

    // MARK: - Properties

    func properties(for url: URL) -> PathProperties {
        let path = url.path

        for rule in rules {
            for pattern in rule.patterns {
                if matchesPattern(path: path, pattern: pattern) {
                    return rule.properties
                }
            }
        }

        // Default properties
        return PathProperties(context: "default", pullToRefreshEnabled: true)
    }

    // MARK: - Pattern Matching

    private func matchesPattern(path: String, pattern: String) -> Bool {
        // Simple pattern matching - can be enhanced with regex
        if pattern == ".*" {
            return true
        }

        // Check if path ends with pattern
        if pattern.hasSuffix("$") {
            let cleanPattern = pattern.replacingOccurrences(of: "$", with: "")
            return path.hasSuffix(cleanPattern)
        }

        return path.contains(pattern)
    }
}

// MARK: - Configuration Model

private struct Configuration: Codable {
    let settings: Settings?
    let rules: [PathConfiguration.Rule]

    struct Settings: Codable {
        let screenshotsEnabled: Bool

        enum CodingKeys: String, CodingKey {
            case screenshotsEnabled = "screenshots_enabled"
        }
    }
}
