//
//  Sortingutilities.swift
//  Sorting-Charts
//
//  Created by Jaimin Raval on 10/09/26.
//
//  SortingUtilities.swift
//  Shared coloring + data-generation helpers used by every sort screen.
//

import SwiftUI

/// The visual/semantic state of a single bar at a given moment in the sort.
enum BarRole: Equatable {
    case normal
    case active    // currently being compared
    case pivot     // quicksort pivot / selection-sort current minimum candidate
    case sorted    // has reached its final position
    case merging   // part of the range currently being merged (merge sort)

    var color: Color {
        switch self {
        case .normal: return .blue
        case .active: return .red
        case .pivot: return .orange
        case .sorted: return .green
        case .merging: return .purple
        }
    }
}

enum SortingUtilities {
    static func randomValues(count: Int = 12) -> [Int] {
        (0..<count).map { _ in Int.random(in: 5...100) }
    }
}
