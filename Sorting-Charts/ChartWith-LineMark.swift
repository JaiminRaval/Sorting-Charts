//
//  ChartWith-LineMark.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 11/09/26.
//

import SwiftUI
import Charts

struct ChartWith_LineMark: View {
    
    var numbers:[Int] = [0,1,2,3,4,5,7]
    var body: some View {
        Chart {
            ForEach(Array(numbers.enumerated()), id: \.offset) { index, value in
                BarMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
//                .foregroundStyle(barColor(for: index))
                .cornerRadius(4)
            }

            // Separate ForEach so the line renders as one continuous mark,
            // not disconnected per-bar
            ForEach(Array(numbers.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom) // smooths the line; use .linear for straight segments

                PointMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(.orange)
                .symbolSize(30)
            }
        }
        .frame(height: 260)
        .animation(.easeInOut(duration: 0.15), value: numbers)
    }
}

#Preview {
    ChartWith_LineMark()
}
