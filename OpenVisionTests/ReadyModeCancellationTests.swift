import XCTest
@testable import OpenVision

final class ReadyModeCancellationTests: XCTestCase {
    @MainActor
    func testStoppedRequestDoesNotStartProcessingOrDeliverAReply() async {
        let service = OpenAIService.shared
        let previousMessage = service.onAgentMessage
        let previousProcessing = service.onProcessingChanged
        defer {
            service.onAgentMessage = previousMessage
            service.onProcessingChanged = previousProcessing
        }
        var deliveredReply = false
        var startedProcessing = false
        service.onAgentMessage = { _ in deliveredReply = true }
        service.onProcessingChanged = { if $0 { startedProcessing = true } }

        let request = Task { @MainActor in
            withUnsafeCurrentTask { $0?.cancel() }
            try await service.sendMessage("This stopped conversation must stay silent")
        }
        do {
            try await request.value
            XCTFail("A canceled conversation must not start a request")
        } catch is CancellationError {
            // Must happen before configuration checks, tools, networking, or speech callbacks.
        } catch {
            XCTFail("Expected cancellation, got \(error)")
        }
        XCTAssertFalse(startedProcessing)
        XCTAssertFalse(deliveredReply)
    }
}
