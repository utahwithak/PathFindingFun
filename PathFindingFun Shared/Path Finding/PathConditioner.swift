//
//  PathConditioner.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

protocol PathConditioner {
    /// Called for every node but the start & goal and should return true, if this point is usable
    func validNode(at pt: MapPoint) -> Bool

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool
}
