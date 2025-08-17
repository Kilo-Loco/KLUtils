//
//  AudioRecorder.swift
//
//
//  Created by Kilo Loco on 11/22/23.
//

import AVFoundation
import Combine

public class AudioRecorder: NSObject, ObservableObject {
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioLevel: Float = 0.0
    var isRecording = false

    private var timer: Timer?

    public override init() {
        super.init()
        setupRecordingSession()
    }

    private func setupRecordingSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        // Handle the failure to get permission
                        print("Error: Permission for recording audio has not been granted")
                    }
                }
            }
        } catch {
            // Handle the error
            print("Error: \(error)")
        }
    }

    public func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true
            startMetering()
        } catch {
            stopRecording()
        }
    }

    public func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopMetering()
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func startMetering() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self, self.isRecording else {
                timer.invalidate()
                return
            }

            self.audioRecorder?.updateMeters()
            self.audioLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
            // Update waveform view here
        }
    }

    private func stopMetering() {
        guard self.timer?.isValid == true else { return }
        self.timer?.invalidate()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    // Implement delegate methods if needed
}

