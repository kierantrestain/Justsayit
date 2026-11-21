import Foundation

nonisolated enum AppIdentity {
    static let name = "Just Say It"
    static let repositoryOwner = "kierantrestain"
    static let repositoryName = "Justsayit"

    static func githubURL(_ path: String = "") -> URL? {
        let suffix = path.isEmpty || path.hasPrefix("#") ? path : "/" + path
        return URL(string: "https://github.com/\(self.repositoryOwner)/\(self.repositoryName)\(suffix)")
    }
}

extension Bundle {
    var fluidAppDisplayName: String {
        let displayName = self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = self.object(forInfoDictionaryKey: "CFBundleName") as? String
        return [displayName, bundleName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? AppIdentity.name
    }
}
