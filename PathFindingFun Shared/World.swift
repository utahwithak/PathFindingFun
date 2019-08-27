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
        result.y = -CGFloat(point.y * World.TileSize)
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

    func setBuildQuality(at pt: MapPoint, to bq: BuildQuality) -> Bool {
        let oldBQ = node(at: pt).buildQuality
        nodes[index(of: pt)].buildQuality = bq
        return oldBQ != bq;
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

    func secondNeighbor(of initial: MapPoint, direction: Int) -> MapPoint {
        var pt = initial
        precondition(direction < 12 )

        let yShift = [0, -1, -2, -2, -2, -1, 0, 1, 2, 2, 2, 1]

        switch(direction)
        {
            case 0: pt.x -= 2
            case 1: pt.x -= 2 - (((pt.y & 1) != 0) ? 1 : 0)
            case 2: pt.x -= 1
            case 3: break;
            case 4: pt.x += 1
            case 5: pt.x += 2 - (((pt.y & 1) != 0) ? 0 : 1)
            case 6: pt.x += 2
            case 7: pt.x += 2 - (((pt.y & 1) != 0) ? 0 : 1)
            case 8: pt.x += 1
            case 9: break;
            case 10: pt.x -= 1; break;
            default: pt.x -= 2 - (((pt.y & 1) != 0) ? 1 : 0)
        }

        pt.y += yShift[direction];

        if direction > 3 && direction < 9 {
            pt.x %= width
        }

        if direction > 6 {
            pt.y %= height
        }

        if pt.x < 0 {
            pt.x += width
        }

        if pt.y < 0 {
            pt.y += height
        }
        return pt;
    }


    func buildQuality(at pt: MapPoint, for player: Int) -> BuildQuality {
        let nodeQuality = node(at: pt).buildQuality

        if nodeQuality == .nothing || !isPlayerTerritory(player: player, at: pt) {
            return .nothing
        }


        if nodeQuality != .flag && !isPlayerTerritory(player: player, at: neighbor(of: pt, direction: .southeast)) {
            if let bm = object(at: neighbor(of: pt, direction: .west))?.blockingType, bm == .flag {
                return .nothing
            }
            if let bm = object(at: neighbor(of: pt, direction: .northwest))?.blockingType, bm == .flag {
                return .nothing
            }
            if let bm = object(at: neighbor(of: pt, direction: .northeast))?.blockingType, bm == .flag {
                return .nothing
            }

            return .flag;
        } else {
            return nodeQuality;
        }
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

    func isPlayerTerritory(player: Int, at pt: MapPoint) -> Bool {
        return true
    }

    func buildRoad(at pt: MapPoint, route: [Direction], for player: Int) {
        guard route.count >= 2 else {
            assert(false)
        }

        guard let flag = object(at: pt) as? Flag else {
            print("Failed to create road, no flag!")
            return
        }
        let roadChecker = PathConditionRoad(world: self, player: player)
        var curPt = pt
        for dir in route.dropLast() {
            let isValidEdge = roadChecker.validEdge(from: curPt, in: dir)
            curPt = neighbor(of: curPt, direction: dir)
            if !isValidEdge {
                print("FAILED to build road, check if built already!")
                return
            }
        }

        guard let lastDirection = route.last else {
            return
        }
        curPt = neighbor(of: curPt, direction: lastDirection)

        if let endFlag = object(at: curPt) as? Flag {
            guard endFlag.playerId == player else {
                print("Found Flag for wrong player!")
                return
            }
        } else {
            if buildQuality(at: curPt, for: player) == .nothing || hasFlagAround(pt: curPt) {
                print("Failed to create route. can't create end flag!")
                return;
            }

            placeFlag(at: curPt, for: player, direction: lastDirection.reversed)
        }


        var end = pt
        for dir in route {
            setPointRoad(at: end, direction: dir, type: Road.RoadType.regular)
            updateBuildQualityForRoad(at: end);
            end = neighbor(of: end, direction: dir)

        }

        guard let endFlag = object(at: curPt) as? Flag else {
            fatalError("Don't have end flag!")
        }
        let road = Road(from: flag, to: endFlag, route: route)

        flag.update(road: road, from: route[0])
        endFlag.update(road: road, from: lastDirection.reversed)
//
//            GetSpecObj<noFlag>(start)->SetRoute(route.front(), rs);
//            GetSpecObj<noFlag>(end)->SetRoute(route.back() + 3u, rs);
//
//            // Der Wirtschaft mitteilen, dass eine neue Straße gebaut wurde, damit sie alles Nötige macht
//            GetPlayer(playerId).NewRoadConnection(rs);
//            GetNotifications().publish(RoadNote(RoadNote::Constructed, playerId, start, route));

    }

    func placeFlag(at pt: MapPoint, for player: Int, direction: Direction? = nil) {

        guard buildQuality(at: pt, for: player) != .nothing else {
            print("Failed to place flag, BQ")
            return
        }

        guard !hasFlagAround(pt: pt) else {
            print("failed to place flag, flag around")
            return
        }

        guard !(object(at: pt) is Flag) else {
            print("Failed to place flag, already one there!")
            return
        }
        print("Destroy what is there!")
        setObject(Flag(at: pt, player: player), at: pt)
        updateBuildQuality(around: pt, radius: .extended)

    }

    func isOnRoad(at pt: MapPoint) -> Bool {
        for roadDir in Direction.westNorth {
            if hasRoad(at: pt, in: roadDir) || hasRoad(at: neighbor(of: pt, direction: roadDir), in: roadDir) {
                return true;
            }
        }


        return false;
    }

    func hasFlagAround(pt: MapPoint) -> Bool {
        for dir in Direction.allDirections {
            if let blockingType = object(at: neighbor(of: pt, direction: dir))?.blockingType, blockingType == .flag {
                return true
            }
        }
        return false;
    }

    enum UpdateBuildQualityRadius {
        case simple
        case extended
    }

    func updateBuildQuality(around pt: MapPoint, radius: UpdateBuildQualityRadius = .simple) {

        updateBuildQuality(at: pt)
        for direction in Direction.allDirections {
            updateBuildQuality(at: neighbor(of: pt, direction: direction))
        }

        if radius == .extended {
            for i in 0..<12 {
                updateBuildQuality(at: secondNeighbor(of: pt, direction: i))
            }
        }
    }

    func updateBuildQuality(at pt: MapPoint) {
        let calculator = BuildQualityCalculator(world: self)
        
        if setBuildQuality(at: pt, to: calculator.buildQuality(for: pt, flagOnly: false)) {
            print("Changed Build Quality!")
        }
    }

    func updateBuildQualityForRoad(at pt: MapPoint) {
        updateBuildQuality(at: pt)
        updateBuildQuality(at: neighbor(of: pt, direction: .east))
        updateBuildQuality(at: neighbor(of: pt, direction: .southeast))
        updateBuildQuality(at: neighbor(of: pt, direction: .southwest))
    }
}
