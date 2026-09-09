//
//  ContentView.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 09/09/26.
//
//
//  BubbleSortChartView.swift
//
//  Requires iOS 16+ (Swift Charts).
//  Visualizes bubble sort as a bar chart and plays a live-generated
//  sine-wave "beep" via AVAudioEngine on every comparison/swap.
//

import SwiftUI
import Charts
import AVFoundation

// MARK: - Tone generator (pure AVFoundation, no audio files needed)

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

    /// Plays a short sine tone at the given frequency.
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
            // simple triangular fade-in/out envelope to avoid clicks
            let distanceFromEdge = min(t, duration - t)
            let envelope = Float(max(0, min(distanceFromEdge / half, 1)))
            data[frame] = Float(sin(2.0 * .pi * frequency * t)) * amplitude * envelope
        }

        // .interrupts cuts off any tone still queued so beeps stay snappy
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
    }
}

// MARK: - Bubble sort view

struct BubbleSortChartView: View {
    @State private var numbers: [Int] = BubbleSortChartView.randomNumbers()
    @State private var comparingIndices: (Int, Int)? = nil
    @State private var sortedBoundary: Int = 0
    @State private var isSorting = false

    @State private var tone = ToneGenerator()

    static func randomNumbers(count: Int = 12) -> [Int] {
        (0..<count).map { _ in Int.random(in: 5...100) }
    }

    var body: some View {
        VStack(spacing: 24) {
            Chart {
                ForEach(Array(numbers.enumerated()), id: \.offset) { index, value in
                    BarMark(
                        x: .value("Index", index),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(barColor(for: index))
                    .cornerRadius(4)
                }
            }
            .frame(height: 260)
            .animation(.easeInOut(duration: 0.15), value: numbers)
            .padding(.horizontal)

            HStack(spacing: 16) {
                Button(isSorting ? "Sorting…" : "Start Bubble Sort") {
                    Task { await runBubbleSort() }
                }
                .disabled(isSorting)

                Button("Shuffle") {
                    numbers = Self.randomNumbers()
                    sortedBoundary = 0
                    comparingIndices = nil
                }
                .disabled(isSorting)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func barColor(for index: Int) -> Color {
        if let (i, j) = comparingIndices, index == i || index == j {
            return .red
        } else if index >= numbers.count - sortedBoundary {
            return .green
        } else {
            return .blue
        }
    }

    @MainActor
    private func runBubbleSort() async {
        isSorting = true
        var array = numbers
        let n = array.count

        for i in 0..<n {
            var swappedAny = false
            for j in 0..<(n - i - 1) {
                comparingIndices = (j, j + 1)

                // Pitch scales with the value being compared
                tone.play(frequency: 200 + Double(array[j]) * 4)
                try? await Task.sleep(nanoseconds: 180_000_000)

                if array[j] > array[j + 1] {
                    array.swapAt(j, j + 1)
                    numbers = array
                    swappedAny = true
                    // A slightly longer, higher blip marks an actual swap
                    tone.play(frequency: 200 + Double(array[j]) * 4, duration: 0.12)
                    try? await Task.sleep(nanoseconds: 180_000_000)
                }
            }
            sortedBoundary += 1
            if !swappedAny { break }
        }

        comparingIndices = nil
        sortedBoundary = n
        isSorting = false
    }
}

// MARK: - Preview

#Preview {
    BubbleSortChartView()
}
