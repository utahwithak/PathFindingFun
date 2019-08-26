//
//  World.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

typealias MapPoint = Point<Int>

class World {
    static let TileSize = 50
    public private(set) var nodes: [MapNode]

    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        nodes = [MapNode](repeating: MapNode(), count: width * height)

    }

    func position(of point: MapPoint) -> CGPoint {

        var result = CGPoint(x: point.x * World.TileSize, y: 0)

        if (point.y & 1) != 0 {
            result.x += CGFloat(World.TileSize / 2)
        }
        result.y = CGFloat(point.y * World.TileSize)
        return result
    }

}
