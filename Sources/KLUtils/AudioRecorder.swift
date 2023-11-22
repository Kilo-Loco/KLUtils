//
//  AudioRecorder.swift
//
//
//  Created by Kilo Loco on 11/22/23.
//

import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioLevel: Float = 0.0
    var isRecording = false

    override init() {
        super.init()
        setupRecordingSession()
    }

    func startRecording() {
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

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    private func setupRecordingSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        // Handle the failure to get permission
                    }
                }
            }
        } catch {
            // Handle the error
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func startMetering() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, self.isRecording else {
                timer.invalidate()
                return
            }

            self.audioRecorder?.updateMeters()
            self.audioLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
            // Update waveform view here
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    // Implement delegate methods if needed
}

