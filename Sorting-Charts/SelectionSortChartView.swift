//
//  SelectionSortChartView.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  SelectionSortChartView.swift
//  Selection sort screen. Requires iOS 16+ (Swift Charts).
//

import SwiftUI

struct SelectionSortChartView: View {
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
                Button(isSorting ? "Sorting…" : "Start Selection Sort") {
                    Task { await runSelectionSort() }
                }
                .disabled(isSorting)

                Button("Shuffle") { reset() }
                    .disabled(isSorting)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Selection Sort")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reset() {
        values = SortingUtilities.randomValues()
        roles = Array(repeating: .normal, count: values.count)
    }

    @MainActor
    private func runSelectionSort() async {
        isSorting = true
        let n = values.count

        for i in 0..<n {
            var minIndex = i
            roles[i] = .pivot
            tone.play(frequency: 200 + Double(values[i]) * 4, duration: 0.08)
            try? await Task.sleep(nanoseconds: 120_000_000)

            for j in (i + 1)..<n {
                roles[j] = .active
                tone.play(frequency: 200 + Double(values[j]) * 4)
                try? await Task.sleep(nanoseconds: 120_000_000)

                if values[j] < values[minIndex] {
                    if minIndex != i { roles[minIndex] = .normal }
                    minIndex = j
                    roles[minIndex] = .pivot
                } else {
                    roles[j] = .normal
                }
            }

            if minIndex != i {
                values.swapAt(i, minIndex)
                tone.play(frequency: 200 + Double(values[i]) * 4, duration: 0.12)
                try? await Task.sleep(nanoseconds: 130_000_000)
                roles[minIndex] = .normal
            }

            roles[i] = .sorted
        }

        isSorting = false
    }
}

#Preview {
    NavigationStack { SelectionSortChartView() }
}
