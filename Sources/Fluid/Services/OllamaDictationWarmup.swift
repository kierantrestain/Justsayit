import Foundation

/// A best-effort model preload for the loopback Ollama server. It carries no dictation content.
nonisolated struct OllamaDictationWarmup: Equatable {
    let endpoint: URL
    let model: String

    init?(baseURL: String, model: String) {
        let model = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedModel = model.lowercased()
        guard !model.isEmpty, !lowercasedModel.hasSuffix(":cloud"), !lowercasedModel.hasSuffix("-cloud"),
              var components = URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              let host = components.host?.lowercased(),
              ["localhost", "127.0.0.1", "::1", "[::1]"].contains(host),
              components.scheme == "http" || components.scheme == "https",
              components.path == "/v1" || components.path == "/v1/",
              components.user == nil, components.password == nil, components.query == nil, components.fragment == nil
        else { return nil }

        components.path = "/api/generate"
        guard let endpoint = components.url else { return nil }
        self.endpoint = endpoint
        self.model = model
    }

    func makeRequest() throws -> URLRequest {
        var request = URLRequest(url: self.endpoint, timeoutInterval: 45)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(Payload(model: self.model))
        return request
    }

    func run() async {
        guard !Task.isCancelled, let request = try? self.makeRequest() else { return }
        _ = try? await URLSession.shared.data(for: request, delegate: NoRedirects())
    }

    private struct Payload: Encodable {
        let model: String
        let stream = false
        let keepAlive = "30m"
    }

    private final class NoRedirects: NSObject, URLSessionTaskDelegate {
        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            willPerformHTTPRedirection response: HTTPURLResponse,
            newRequest request: URLRequest,
            completionHandler: @escaping (URLRequest?) -> Void
        ) {
            completionHandler(nil)
        }
    }
}
