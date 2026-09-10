//
//  SortingBarChart.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  SortingBarChart.swift
//  Shared Swift Charts bar chart used by every sort screen.
//  x = index (fixed position), y = value; bars change height/color as
//  the algorithm progresses, which is what gives the "sorting" motion.
//

import SwiftUI
import Charts

struct SortingBarChart: View {
    let values: [Int]
    let roles: [BarRole]

    var body: some View {
        Chart {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                BarMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(roles.indices.contains(index) ? roles[index].color : .blue)
                .cornerRadius(4)
            }
        }
        .frame(height: 260)
        .animation(.easeInOut(duration: 0.15), value: values)
        .padding(.horizontal)
    }
}
