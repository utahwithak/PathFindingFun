//
//  FreeWorldPathFinder.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

struct PathResult {
    let route: [Direction]
    let start: MapPoint
    let end: MapPoint
}

class FreeWorldPathFinder {

    private var currentVisit: UInt = 0
    private var width: Int
    private var height: Int

    private var pathNodes = [PathNode]()

    init(world: World) {
        width = world.width
        height = world.height
        pathNodes.reserveCapacity(width * height)
        for y in 0..<height {
            for x in 0..<width {
                let pt = MapPoint(x, y)
                let idx = world.index(of: pt)
                pathNodes.append(PathNode(idx: idx, pt: pt))
            }
        }
    }


    struct PathNode: Comparable {
        /// Indicator if node was visited (lastVisited == currentVisit)
        var lastVisited: UInt = 0
        /// Previous node
        var previousNode: Int = -1

        /// Distance from start to this node
        var curDistance: Int = 0

        /// Distance from node to target
        var targetDistance: Int = 0
        /// Distance from start over thise node to target (== curDistance + targetDistance)
        var estimatedDistance: Int = 0

        /// Index used to distinguish nodes with same estimate
        let idx: Int

        /// Point on map which this node represents
        let mapPt: MapPoint

        init(idx: Int, pt: MapPoint) {
            self.idx = idx
            self.mapPt = pt
        }

        /// Direction used to reach this node
        var dir: Direction = .west

        var position = 0

        static func <(lhs: PathNode, rhs: PathNode) -> Bool {
            return lhs.estimatedDistance < rhs.estimatedDistance
        }
    }

    private func increaseCurrentVisit() {
        // if the counter reaches its maxium, tidy up
        if currentVisit == UInt.max {
            for i in 0..<(width * height) {
                pathNodes[i].lastVisited = 0
            }
            currentVisit = 1
        } else {
            currentVisit += 1
        }
    }

    final func findPath(from start: MapPoint, to dest: MapPoint, in world: World, validator: PathConditioner) -> PathResult? {
        assert(start != dest)

        // increase currentVisit, so we don't have to clear the visited-states at every run
        increaseCurrentVisit()

        var todo = [PathNode]()

        let startId = world.index(of: start)
        let destId  = world.index(of: dest)
        let startNode = pathNodes[startId]
        let destNode  = pathNodes[destId]

        // Anfangsknoten einfügen Und mit entsprechenden Werten füllen
        pathNodes[startId].targetDistance = world.distance(from: start, to: dest)
        pathNodes[startId].estimatedDistance = startNode.targetDistance
        pathNodes[startId].lastVisited = currentVisit
        pathNodes[startId].previousNode = -1
        pathNodes[startId].curDistance = 0
        pathNodes[startId].dir = .west

        todo.sortedInsert(newElement: startNode)

        while !todo.isEmpty {

            let best = todo.removeFirst()

            if best.idx == destNode.idx {
                var route = [Direction]()
                var curNode = best
                for _ in stride(from:best.curDistance - 1, through: 0, by: -1) {
                    route.append(curNode.dir)
                    curNode = pathNodes[curNode.previousNode]
                }
                assert(curNode.idx == startNode.idx)

                return PathResult(route: route.reversed(), start: start, end: dest)
            }

            for dir in Direction.allDirections {
                let neighborPos = world.neighbor(of: best.mapPt, direction: dir)
                let nbId = world.index(of: neighborPos)
                let neighbor = pathNodes[nbId]

                if best.previousNode == neighbor.idx {
                    continue
                }

                if neighbor.lastVisited == currentVisit {

                    if best.curDistance + 1 < neighbor.curDistance {
                        // Check if we can use this transition
                        if !validator.validEdge(from: best.mapPt, in: dir) {
                            continue
                        }

                        pathNodes[nbId].curDistance  = best.curDistance + 1
                        pathNodes[nbId].estimatedDistance = neighbor.curDistance + neighbor.targetDistance
                        pathNodes[nbId].previousNode = best.idx
                        pathNodes[nbId].dir = dir
                        todo.sortedInsert(newElement: pathNodes[nbId])
                    }
                } else {
                    // Check node for all but the goal (goal is assumed to be ok)
                    if neighbor.idx != destNode.idx  && !validator.validNode(at: neighborPos) {
                        continue
                    }

                    // Check if we can use this transition
                    if !validator.validEdge(from: best.mapPt, in: dir) {
                        continue
                    }

                    // Alles in Ordnung, Knoten kann gebildet werden
                    pathNodes[nbId].lastVisited = currentVisit
                    pathNodes[nbId].curDistance = best.curDistance + 1
                    pathNodes[nbId].targetDistance = world.distance(from: neighborPos, to: dest)
                    pathNodes[nbId].estimatedDistance = neighbor.curDistance + neighbor.targetDistance
                    pathNodes[nbId].dir = dir
                    pathNodes[nbId].previousNode = best.idx

                    todo.sortedInsert(newElement: pathNodes[nbId])
                }
            }
        }

        return nil

    }

}

struct AllValidPathConditioner: PathConditioner {
    func validNode(at pt: MapPoint) -> Bool {
        return true
    }

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool {
        return true
    }
}

struct PathConditionHuman: PathConditioner {

    let world: World

    init(world: World) {
        self.world = world
    }

    func validNode(at pt: MapPoint) -> Bool {
        if let bm = world.object(at: pt)?.blockingType, bm != .none && bm != .tree && bm != .flag {
            return false
        }

//        // If no terrain around this is usable, we can't go here
//        for dir in Direction.allDirections {
//            if world.terrainAround(point: pt, dir: dir).isUsable {
//                return true
//            }
//        }
        return false


    }

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool {
        return true//world.validNodeToNode(from:pt, in: direction)
    }

}

struct PathConditionRoad: PathConditioner {
    let world: World

    func validNode(at pt: MapPoint) -> Bool {
        return world.isPlayersTerritory(at: pt) && world.canBuildRoad(at: pt)
    }

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool {
        return true//world.validNodeToNode(from:pt, in: direction)
    }
}

struct NoWrappingPathCondition: PathConditioner {
    let world: World

    func validNode(at pt: MapPoint) -> Bool {
        return true
    }

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool {
        let neighbor = world.neighbor(of: pt, direction: direction)
        if pt.x == 0 && neighbor.x == world.width - 1 {
            return false
        }
        if pt.y == 0 && neighbor.y == world.height - 1 {
            return false
        }
        if pt.x == world.width - 1 && neighbor.x == 0 {
            return false
        }
        if pt.y == world.height - 1 && neighbor.y == 0 {
            return false
        }

        return true
    }
}

struct PathConditionerCombiner: PathConditioner {
    let v1: PathConditioner
    let v2: PathConditioner

    func validNode(at pt: MapPoint) -> Bool {
        return v1.validNode(at: pt) && v2.validNode(at: pt)
    }

    func validEdge(from pt: MapPoint, in direction: Direction) -> Bool {
        return v1.validEdge(from: pt, in: direction) && v2.validEdge(from: pt, in: direction)
    }
}
