//
//  Direction.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

enum Direction: UInt8 {
    case west = 0
    case northwest
    case northeast
    case east
    case southeast
    case southwest

    static let allDirections: [Direction] = [.west, .northwest, .northeast, .east, .southeast, .southwest]

    var isEastOrSouth: Bool {
        return self == .east || self == .southeast || self == .southwest
    }

    var isWestOrNorth: Bool {
        return self == .west || self == .northeast || self == .northwest
    }

    var reversed: Direction {
        switch self {
        case .east:
            return .west
        case .west:
            return .east
        case .southwest:
            return .northeast
        case .southeast:
            return .northwest
        case .northwest:
            return .southeast
        case .northeast:
            return .southwest
        }
    }
}
