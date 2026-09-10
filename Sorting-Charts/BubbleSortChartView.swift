//
//  ContentView.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 09/09/26.
//
//
//  BubbleSortChartView.swift
//  Bubble sort screen. Requires iOS 16+ (Swift Charts).
//

import SwiftUI

struct BubbleSortChartView: View {
    @State private var values: [Int]
    @State private var roles: [BarRole]
    @State private var isSorting = false
    @State private var tone = ToneGenerator()

    init() {
        let initial = SortingUtilities.randomValues()
        _values = State(initialValue: initial)
        _roles = State(initialValue: Array(repeating: .normal, count: initial.count))
    }

    var body: some View {
        VStack(spacing: 24) {
            SortingBarChart(values: values, roles: roles)

            HStack(spacing: 16) {
                Button(isSorting ? "Sorting…" : "Start Bubble Sort") {
                    Task { await runBubbleSort() }
                }
                .disabled(isSorting)

                Button("Shuffle") { reset() }
                    .disabled(isSorting)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Bubble Sort")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reset() {
        values = SortingUtilities.randomValues()
        roles = Array(repeating: .normal, count: values.count)
    }

    @MainActor
    private func runBubbleSort() async {
        isSorting = true
        let n = values.count

        for i in 0..<n {
            var swappedAny = false
            for j in 0..<(n - i - 1) {
                roles[j] = .active
                roles[j + 1] = .active
                tone.play(frequency: 200 + Double(values[j]) * 4)
                try? await Task.sleep(nanoseconds: 180_000_000)

                if values[j] > values[j + 1] {
                    values.swapAt(j, j + 1)
                    swappedAny = true
                    tone.play(frequency: 200 + Double(values[j]) * 4, duration: 0.12)
                    try? await Task.sleep(nanoseconds: 180_000_000)
                }

                roles[j] = .normal
                roles[j + 1] = .normal
            }
            roles[n - i - 1] = .sorted
            if !swappedAny { break }
        }

        for idx in roles.indices where roles[idx] != .sorted { roles[idx] = .sorted }
        isSorting = false
    }
}

#Preview {
    NavigationStack { BubbleSortChartView() }
}
