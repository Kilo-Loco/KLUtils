import XCTest
import AVFoundation
@testable import KLUtils

final class KLUtilsTests: XCTestCase {
    var audioRecorder: AudioRecorder!
    let recordingFileName: String = "rec.m4a"

    override func setUp() {
        self.audioRecorder = .init()
    }

    override func tearDown() {
        self.audioRecorder = nil
    }

    func testAudioRecorder_recordingSessionIsSetup() {
        XCTAssertEqual( self.audioRecorder.audioSession.category, .playAndRecord)
    }

    func testAudioRecorder_startRecording() {
        
        self.audioRecorder.startRecording(in: recordingFileName)
        XCTAssertTrue(self.audioRecorder.isRecording)
    }

    func testAudioRecorder_stopRecording() {
        self.audioRecorder.startRecording(in: recordingFileName)
        self.audioRecorder.stopRecording()
        XCTAssertFalse(self.audioRecorder.isRecording)
    }
}
