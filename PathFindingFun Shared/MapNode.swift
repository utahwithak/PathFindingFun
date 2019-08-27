//
//  Node.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

struct MapNode {
    var roads: [Road.RoadType] = [.none, .none, .none]

    var buildQuality: BuildQuality = .flag

    var mapObject: MapObject?
}
