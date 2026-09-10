//
//  QuickSortChartView.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  QuickSortChartView.swift
//  Quick sort screen (Lomuto partition). Requires iOS 16+ (Swift Charts).
//

import SwiftUI

struct QuickSortChartView: View {
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
                Button(isSorting ? "Sorting…" : "Start Quick Sort") {
                    Task { await runQuickSort() }
                }
                .disabled(isSorting)

                Button("Shuffle") { reset() }
                    .disabled(isSorting)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Quick Sort")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reset() {
        values = SortingUtilities.randomValues()
        roles = Array(repeating: .normal, count: values.count)
    }

    @MainActor
    private func runQuickSort() async {
        isSorting = true
        roles = Array(repeating: .normal, count: values.count)
        await quickSort(low: 0, high: values.count - 1)
        roles = Array(repeating: .sorted, count: values.count)
        isSorting = false
    }

    /// Standard Lomuto partition scheme, using the last element as pivot.
    @MainActor
    private func quickSort(low: Int, high: Int) async {
        guard low < high else {
            if low >= 0 && low < roles.count { roles[low] = .sorted }
            return
        }

        let pivotValue = values[high]
        roles[high] = .pivot
        tone.play(frequency: 200 + Double(pivotValue) * 4, duration: 0.1)
        try? await Task.sleep(nanoseconds: 150_000_000)

        var i = low
        for j in low..<high {
            roles[j] = .active
            tone.play(frequency: 200 + Double(values[j]) * 4)
            try? await Task.sleep(nanoseconds: 130_000_000)

            if values[j] < pivotValue {
                values.swapAt(i, j)
                i += 1
            }
            roles[j] = .normal
        }

        values.swapAt(i, high)
        roles[high] = .normal
        roles[i] = .sorted
        tone.play(frequency: 200 + Double(values[i]) * 4, duration: 0.12)
        try? await Task.sleep(nanoseconds: 150_000_000)

        await quickSort(low: low, high: i - 1)
        await quickSort(low: i + 1, high: high)
    }
}

#Preview {
    NavigationStack { QuickSortChartView() }
}
