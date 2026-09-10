//
//  MergeSortChartView.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  MergeSortChartView.swift
//  Merge sort screen. Requires iOS 16+ (Swift Charts).
//

import SwiftUI

struct MergeSortChartView: View {
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
                Button(isSorting ? "Sorting…" : "Start Merge Sort") {
                    Task { await runMergeSort() }
                }
                .disabled(isSorting)

                Button("Shuffle") { reset() }
                    .disabled(isSorting)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Merge Sort")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reset() {
        values = SortingUtilities.randomValues()
        roles = Array(repeating: .normal, count: values.count)
    }

    @MainActor
    private func runMergeSort() async {
        isSorting = true
        roles = Array(repeating: .normal, count: values.count)
        await mergeSort(low: 0, high: values.count - 1)
        roles = Array(repeating: .sorted, count: values.count)
        isSorting = false
    }

    @MainActor
    private func mergeSort(low: Int, high: Int) async {
        guard low < high else { return }
        let mid = (low + high) / 2
        await mergeSort(low: low, high: mid)
        await mergeSort(low: mid + 1, high: high)
        await merge(low: low, mid: mid, high: high)
    }

    /// Merges the two already-sorted halves [low...mid] and [mid+1...high].
    @MainActor
    private func merge(low: Int, mid: Int, high: Int) async {
        for k in low...high { roles[k] = .merging }
        tone.play(frequency: 260, duration: 0.05)
        try? await Task.sleep(nanoseconds: 80_000_000)

        let left = Array(values[low...mid])
        let right = Array(values[(mid + 1)...high])
        var i = 0, j = 0, k = low

        while i < left.count && j < right.count {
            roles[k] = .active
            let winner = left[i] <= right[j] ? left[i] : right[j]
            tone.play(frequency: 200 + Double(winner) * 4)
            try? await Task.sleep(nanoseconds: 120_000_000)

            if left[i] <= right[j] {
                values[k] = left[i]
                i += 1
            } else {
                values[k] = right[j]
                j += 1
            }
            roles[k] = .merging
            k += 1
        }

        while i < left.count {
            values[k] = left[i]
            roles[k] = .merging
            tone.play(frequency: 200 + Double(left[i]) * 4, duration: 0.06)
            try? await Task.sleep(nanoseconds: 90_000_000)
            i += 1
            k += 1
        }

        while j < right.count {
            values[k] = right[j]
            roles[k] = .merging
            tone.play(frequency: 200 + Double(right[j]) * 4, duration: 0.06)
            try? await Task.sleep(nanoseconds: 90_000_000)
            j += 1
            k += 1
        }

        try? await Task.sleep(nanoseconds: 100_000_000)
        for idx in low...high { roles[idx] = .normal }
    }
}

#Preview {
    NavigationStack { MergeSortChartView() }
}
