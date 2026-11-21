import Foundation

/// Canonical spellings for distinctive names and products. Ordinary phrases and personal
/// names belong in the opt-in vocabulary, where each speaker chooses their preferred spelling.
nonisolated enum BuiltInDictionary {
    private static let canonicalSpellings = [
        "AirDrop", "AirPods", "AirTag", "AppKit", "Bitbucket", "ChatGPT", "Chromebook", "Cloudflare",
        "CodePen", "DevOps", "FaceTime", "Firefox", "FreeBSD", "GitHub", "GitLab", "GraphQL",
        "iCloud", "iMessage", "iMovie", "iOS", "iPad", "iPadOS", "iPhone", "JavaScript",
        "Kubernetes", "LinkedIn", "macOS", "Nextcloud", "NVIDIA", "OneDrive",
        "OpenAI", "OpenRouter", "PayPal", "PostgreSQL", "PostHog", "PowerPoint", "PowerShell", "Spotify",
        "SwiftUI", "Tailwind CSS", "Thunderbird", "TikTok", "TypeScript", "Ubuntu", "VS Code", "VLC",
        "WhatsApp", "Wi-Fi", "WordPress", "Xcode", "YouTube", "ZoomInfo",
    ]

    static let entries: [SettingsStore.CustomDictionaryEntry] = self.canonicalSpellings.map {
        .init(triggers: [$0.lowercased()], replacement: $0)
    } + [
        .init(triggers: ["claud"], replacement: "Claude"),
        .init(triggers: ["huggingface", "hugging face"], replacement: "Hugging Face"),
        .init(triggers: ["justsayit"], replacement: "Just Say It"),
        .init(triggers: ["mac o s"], replacement: "macOS"),
        .init(triggers: ["visual studio code"], replacement: "Visual Studio Code"),
        .init(triggers: ["wi fi", "wifi"], replacement: "Wi-Fi"),
    ]

    /// Built-in entries without any spelling the user already maps, so the user's choice wins.
    static func entries(excludingSpellingsIn userEntries: [SettingsStore.CustomDictionaryEntry]) -> [SettingsStore.CustomDictionaryEntry] {
        // Exact-case overrides are protected per occurrence by ASRService, not removed globally.
        let taken = Set(userEntries.filter { !$0.caseSensitive }.flatMap(\.triggers).map { $0.lowercased() })
        return self.entries.compactMap { entry in
            let triggers = entry.triggers.filter { !taken.contains($0) }
            return triggers.isEmpty ? nil : SettingsStore.CustomDictionaryEntry(id: entry.id, triggers: triggers, replacement: entry.replacement)
        }
    }
}
