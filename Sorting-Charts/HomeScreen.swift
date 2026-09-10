//
//  HomeScreen.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//
//  HomeView.swift
//  Home screen using Liquid Glass (glassEffect / GlassEffectContainer).
//
//  NOTE: Liquid Glass APIs require iOS 26+ and Xcode 26+. If your
//  deployment target is lower, either raise it to iOS 26 or replace
//  `.glassEffect(...)` below with `.background(.ultraThinMaterial, in: ...)`
//  as a pre-iOS-26 fallback.
//

import SwiftUI

struct HomeView: View {
    private let algorithms: [AlgorithmInfo] = [
        AlgorithmInfo(title: "Bubble Sort", subtitle: "Compare & swap neighbors", systemImage: "arrow.up.arrow.down"),
        AlgorithmInfo(title: "Selection Sort", subtitle: "Pick the minimum each pass", systemImage: "target"),
        AlgorithmInfo(title: "Quick Sort", subtitle: "Partition around a pivot", systemImage: "bolt.fill"),
        AlgorithmInfo(title: "Merge Sort", subtitle: "Divide, sort, and merge", systemImage: "square.stack.3d.up")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.35), .purple.opacity(0.25), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 6) {
                            Text("Sorting Visualizer")
                                .font(.largeTitle.bold())
                            Text("Pick an algorithm to watch it sort — with sound")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)

                        HStack(spacing: 14) {
                            LegendDot(color: .red, label: "Comparing")
                            LegendDot(color: .orange, label: "Pivot")
                            LegendDot(color: .purple, label: "Merging")
                            LegendDot(color: .green, label: "Sorted")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        GlassEffectContainer(spacing: 16) {
                            VStack(spacing: 16) {
                                NavigationLink { BubbleSortChartView() } label: {
                                    AlgorithmCard(info: algorithms[0])
                                }
                                .buttonStyle(.plain)

                                NavigationLink { SelectionSortChartView() } label: {
                                    AlgorithmCard(info: algorithms[1])
                                }
                                .buttonStyle(.plain)

                                NavigationLink { QuickSortChartView() } label: {
                                    AlgorithmCard(info: algorithms[2])
                                }
                                .buttonStyle(.plain)

                                NavigationLink { MergeSortChartView() } label: {
                                    AlgorithmCard(info: algorithms[3])
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct AlgorithmInfo {
    let title: String
    let subtitle: String
    let systemImage: String
}

private struct AlgorithmCard: View {
    let info: AlgorithmInfo

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: info.systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(info.title)
                    .font(.headline)
                Text(info.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .foregroundStyle(.primary)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

#Preview {
    HomeView()
}
