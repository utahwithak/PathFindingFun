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

    func index(of pt: MapPoint) -> Int {
        return pt.y * width + pt.x
    }

    func node(at pt: MapPoint) -> MapNode {
        return nodes[index(of: pt)]
    }

    func object(at pt: MapPoint) -> MapObject? {
        return node(at: pt).mapObject
    }

    func setObject(_ obj: MapObject, at pt: MapPoint) {
        nodes[index(of: pt)].mapObject = obj
    }

    func setPointRoad(at pt: MapPoint, direction: Direction, type: Road.RoadType) {
        if direction.isEastOrSouth {
            setNodeRoad(at: pt, in: direction.reversed, to: type)
        } else {
            setNodeRoad(at: neighbor(of: pt, direction: direction), in: direction, to: type)
        }

    }

    func setNodeRoad(at pt: MapPoint, in direction: Direction, to type: Road.RoadType) {
        assert(direction.isWestOrNorth)
        nodes[index(of: pt)].roads[Int(direction.rawValue)] = type
    }

    final func distance( x1: Int, y1: Int, x2: Int, y2: Int) -> Int {
        var dx = ((x1 - x2) * 2) + (y1 & 1) - (y2 & 1)
        var dy = ((y1 > y2) ? (y1 - y2) : (y2 - y1)) * 2

        if dx < 0 {
            dx = -dx
        }

        if dy > Int(height) {
            dy = (Int(height) * 2) - dy
        }

        if dx > Int(width) {
            dx = (Int(width) * 2) - dx
        }

        dx -= dy / 2

        return ((dy + (dx > 0 ? dx : 0)) / 2)
    }

    final func distance(from p1: MapPoint, to p2: MapPoint) -> Int {
        return distance(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }

    final func neighbor(of pt: MapPoint, direction: Direction) -> MapPoint {
        /*  Note that every 2nd row is shifted by half a triangle to the left, therefore:
         Modifications for the dirs:
         current row:    Even    Odd
                      W  -1|0   -1|0
         D           NW  -1|-1   0|-1
         I           NE   0|-1   1|-1
         R            E   1|0    1|0
                     SE   0|1    1|1
                     SW  -1|1    0|1
         */

        var res = MapPoint(x:0, y: 0)
        switch direction {
        case .west: // -1|0   -1|0
            res.x = ((pt.x == 0) ? width : pt.x) - 1
            res.y = pt.y
        case .northwest: // -1|-1   0|-1
            res.x = (pt.y & 1) != 0 ? pt.x : (((pt.x == 0) ? width : pt.x) - 1)
            res.y = ((pt.y == 0) ? height : pt.y) - 1
        case .northeast: // 0|-1  -1|-1
            res.x = (!(pt.y & 1 != 0)) ? pt.x : ((pt.x == width - 1) ? 0 : pt.x + 1)
            res.y = ((pt.y == 0) ? height : pt.y) - 1
        case .east: // 1|0    1|0
            res.x = pt.x + 1
            if(res.x == width) {
                res.x = 0
            }
            res.y = pt.y
        case .southeast: // 1|1    0|1
            res.x = (!(pt.y & 1 != 0)) ? pt.x : ((pt.x == width - 1) ? 0 : pt.x + 1)
            res.y = pt.y + 1
            if(res.y == height) {
                res.y = 0
            }
        case .southwest: // 0|1   -1|1
            res.x = (pt.y & 1 != 0) ? pt.x : (((pt.x == 0) ? width : pt.x) - 1)
            res.y = pt.y + 1
            if(res.y == height) {
                res.y = 0
            }
        }

        return res
    }

    func canBuildRoad(at pt: MapPoint, boatRoad: Bool = false) -> Bool {
        if let object = object(at: pt), object.blockingType != .none {
            return false
        }

//        // dont build on the border
//        if(GetNode(pt).boundary_stones[0])
//            return false;

        for dir in Direction.allDirections {

            if let object = object(at: neighbor(of: pt, direction: dir)), object.blockingType == .nothingAround {
                return false;
            }

            // Other roads at this point?
            if hasRoad(at: pt, in: dir) {
                return false
            }
        }

//        // Terrain (unterscheiden, ob Wasser und Landweg)
//        if(!boat_road)
//        {
//            bool flagPossible = false;
//
//            for(unsigned char i = 0; i < 6; ++i)
//            {
//                TerrainBQ bq = GetDescription().get(GetRightTerrain(pt, Direction::fromInt(i))).GetBQ();
//                if(bq == TerrainBQ::DANGER)
//                    return false;
//                else if(bq != TerrainBQ::NOTHING)
//                    flagPossible = true;
//            }
//
//            return flagPossible;
//        } else
//        {
//            // Beim Wasserweg muss um den Punkt herum Wasser sein
//            if(!IsWaterPoint(pt))
//                return false;
//        }

        return true;
    }

    func hasRoad(at pt: MapPoint, in direction: Direction) -> Bool {
        if direction.isEastOrSouth {
            return road(at: pt, in: direction.reversed) != .none
        } else {
            return road(at: neighbor(of: pt, direction: direction), in: direction) != .none

        }
    }

    func road(at pt: MapPoint, in direction: Direction) -> Road.RoadType {
        return node(at: pt).roads[Int(direction.rawValue)]
    }

    func isPlayersTerritory(at pt: MapPoint) -> Bool {
        return true
    }
}