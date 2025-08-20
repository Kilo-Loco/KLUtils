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
    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioLevel: Float = 0.0
    var isRecording = false

    private var timer: Timer?

    public override init() {
        super.init()
        setupRecordingSession()
    }

    private func setupRecordingSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { allowed in
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

    /// Starts recording in the object's AudioRecorder
    /// - parameter filename: The name of the file, including the file extension (i.e. "rec.m4a")
    public func startRecording(in filename: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)

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
    
    public func playRecording(at filename: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing recording at:", audioFilename.path)
        } catch {
            print("Error playing recording:", error)
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // Implement delegate methods if needed
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("did finish recording successfully: \(flag)")
    }
}

