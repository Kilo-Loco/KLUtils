//
//  AudioRecorderView.swift
//
//
//  Created by Kilo Loco on 11/22/23.
//

import SwiftUI

struct AudioRecorderView: View {
    @StateObject var audioRecorder = AudioRecorder()
    @State var isRecording = false

    var body: some View {
        VStack {
            // Waveform view goes here
            Button(action: {
                if self.isRecording {
                    self.audioRecorder.stopRecording()
                } else {
                    self.audioRecorder.startRecording(in: "recording.m4a")
                }
                self.isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
        }
    }
}
