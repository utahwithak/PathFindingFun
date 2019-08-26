//
//  Road.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

class Road: MapObject {

    enum RoadType {
        case regular
        case none
    }


    weak var f1: RoadTerminal?
    weak var f2: RoadTerminal?

    let route: [Direction]

    let worker = Worker()
    init(from: RoadTerminal, to: RoadTerminal, route: [Direction]) {
        f1 = from
        f2 = to
        self.route = route
    }

    lazy var node: SKShapeNode? = {
        return nil
//        guard let start = f1?.position, let end = f2?.position else {
//            return nil
//        }
//        let pathNode = SKShapeNode()
//        pathNode.position = start
//        pathNode.name = "connection"
//        let pathToDraw = CGMutablePath()
//        pathToDraw.move(to: .zero)
//        pathToDraw.addLine(to: CGPoint(x: end.x - start.x, y: end.y - start.y))
//        pathNode.path = pathToDraw
//        pathNode.strokeColor = .green
//
//        return pathNode
    }()

    func node(in world: World) -> SKNode? {
        return nil
    }

//    var midPoint: CGPoint {
//        guard let f1 = f1, let f2 = f2 else {
//            return .zero
//        }
//        return CGPoint(x: f1.position.x + (f2.position.x - f1.position.x) / 2, y: f1.position.y + (f2.position.y - f1.position.y) / 2)
//    }
//
//    func requestWorker(to flag: Flag) {
//        assert(flag == f1 || flag == f2)
//        guard let f1 = self.f1, let f2 = self.f2 else {
//            return
//        }
//        worker.pickup(from: flag, to: flag == f1 ? f2 : f1)
//    }
  
}
