//
//  PathFinder.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

class PathFinder {

//    var flags = [Flag]()
//
//    func addFlag(at position: CGPoint) -> Flag {
//        let newFlag = Flag(at: position)
//        flags.append(newFlag)
//        return newFlag
//    }
//
//    func flag(at position: CGPoint) -> Flag? {
//        return flags.first(where: { $0.position == position})
//    }
//
//    func flag(for node: SKShapeNode) -> Flag? {
//        return flags.first(where: { $0.node == node })
//    }
//
//    func addRoad(from: Flag, to: Flag) -> Road {
//        if let existingRoad = from.roads.first(where: { ($0.f1 === from && $0.f2 === to) || ($0.f1 === to && $0.f2 === from)}) {
//            return existingRoad
//        }
//
//        let newRoad = Road(from: from, to: to)
//        from.roads.append(newRoad)
//        to.roads.append(newRoad)
//        return newRoad
//    }
//
//
//
//    static func findPath(from: Flag, to goalFlag: Flag) -> [Flag] {
//
//        var cameFrom = [Flag: Flag]()
//        var costSoFar = [from: CGFloat(0)]
//        var possibleSteps = [PathNode(flag: from, cost: 0)]
//
//        while !possibleSteps.isEmpty {
//
//            let current = possibleSteps.removeFirst()
//
//            if current.flag == goalFlag {
//                break
//            }
//
//            for next in current.flag.connectedFlags {
//                let newCost = costSoFar[current.flag]! + current.flag.cost(to: next)
//                if costSoFar[next] == nil || newCost < costSoFar[next]! {
//                    costSoFar[next] = newCost
//                    possibleSteps.sortedInsert(newElement: PathNode(flag: next, cost: newCost + next.estimatedCost(to: goalFlag)))
//                    cameFrom[next] = current.flag
//                }
//            }
//        }
//
//        var path = [Flag]()
//        var current = goalFlag
//
//        while let prev = cameFrom[current] {
//            path.append(current)
//            current = prev
//        }
//
//        if !path.isEmpty {
//            path.append(from)
//        }
//
//        return path.reversed()
//
//    }

}

//struct PathNode: Comparable {
//    static func < (lhs: PathNode, rhs: PathNode) -> Bool {
//        return lhs.cost < rhs.cost
//    }
//
//    let flag: Flag
//    let cost: CGFloat
//}

extension Array where Element : Comparable {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(element: Element) -> Index {
        var slice : SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if element < slice[middle] {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        return slice.startIndex
    }
    /// Inserts a new element in a sorted array.
    ///
    /// - Parameter newElement: The element to insert into the array.
    ///
    /// - Complexity: To find the index for the new element
    ///   it uses a binary search algorithm

    mutating func sortedInsert(newElement: Element) {
        insert(newElement, at: binarySearch(element: newElement) )
    }
}


extension Array {

    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Element) -> Bool) -> Int {
        var slice : SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if predicate(slice[middle]) {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        return slice.startIndex
    }

    mutating func sortedInsert(element: Element, isOrderedBefore: (Element, Element) -> Bool) {
        insert(element, at: binarySearch{isOrderedBefore($0, element)} )
    }

}

