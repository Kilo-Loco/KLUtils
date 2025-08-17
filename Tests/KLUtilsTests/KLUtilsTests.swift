import XCTest
import AVFoundation
@testable import KLUtils

final class KLUtilsTests: XCTestCase {
    var audioRecorder: AudioRecorder!

    override func setUp() {
        self.audioRecorder = .init()
    }

    override func tearDown() {
        self.audioRecorder = nil
    }

    func testAudioRecorder_recordingSessionIsSetup() {
        XCTAssertEqual( self.audioRecorder.recordingSession.category, .playAndRecord)
    }

    func testAudioRecorder_startRecording() {
        self.audioRecorder.startRecording()
        XCTAssertTrue(self.audioRecorder.isRecording)
    }

    func testAudioRecorder_stopRecording() {
        self.audioRecorder.startRecording()
        self.audioRecorder.stopRecording()
        XCTAssertFalse(self.audioRecorder.isRecording)
    }
}
