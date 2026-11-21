@testable import FluidVoice_Debug
import XCTest

final class OllamaDictationWarmupTests: XCTestCase {
    func testPreloadUsesNativeLoopbackEndpointWithoutDictationContent() throws {
        let warmup = try XCTUnwrap(OllamaDictationWarmup(
            baseURL: "http://localhost:11434/v1/",
            model: " qwen2.5:3b-instruct-q4_K_M "
        ))
        let request = try warmup.makeRequest()
        let body = try XCTUnwrap(request.httpBody)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])

        XCTAssertEqual(request.url?.absoluteString, "http://localhost:11434/api/generate")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(Set(payload.keys), Set(["model", "keep_alive", "stream"]))
        XCTAssertEqual(payload["model"] as? String, "qwen2.5:3b-instruct-q4_K_M")
        XCTAssertEqual(payload["keep_alive"] as? String, "30m")
        XCTAssertEqual(payload["stream"] as? Bool, false)
    }

    func testPreloadSkipsNetworkHostsAndCloudModels() {
        XCTAssertNil(OllamaDictationWarmup(baseURL: "https://ollama.com/v1", model: "qwen2.5"))
        XCTAssertNil(OllamaDictationWarmup(baseURL: "http://192.168.1.10:11434/v1", model: "qwen2.5"))
        XCTAssertNil(OllamaDictationWarmup(baseURL: "http://localhost:11434/proxy/v1", model: "qwen2.5"))
        XCTAssertNil(OllamaDictationWarmup(baseURL: "http://localhost:11434/v1", model: "glm-5.3-flash:cloud"))
    }
}
