//
//  ToneGeneration.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  ToneGenerator.swift
//  Shared AVFoundation tone generator used by every sorting screen.
//  Generates short sine-wave "beeps" live — no audio files needed.
//

import AVFoundation

@MainActor
final class ToneGenerator {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        engine.prepare()
        do {
            try engine.start()
            playerNode.play()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    /// Plays a short sine tone at the given frequency (Hz).
    func play(frequency: Double, duration: Double = 0.08) {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let half = duration / 2
        let amplitude: Float = 0.2

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            // Triangular fade-in/out envelope to avoid audible clicks
            let distanceFromEdge = min(t, duration - t)
            let envelope = Float(max(0, min(distanceFromEdge / half, 1)))
            data[frame] = Float(sin(2.0 * .pi * frequency * t)) * amplitude * envelope
        }

        // .interrupts keeps beeps snappy by cutting off anything still queued
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
    }
}
