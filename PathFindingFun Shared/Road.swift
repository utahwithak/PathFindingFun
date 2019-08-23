//
//  Road.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

class Road {

    init(from: Flag, to: Flag) {
        f1 = from
        f2 = to
    }

    weak var f1: Flag?
    weak var f2: Flag?

    lazy var node: SKShapeNode? = {
        guard let start = f1?.position, let end = f2?.position else {
            return nil
        }
        let pathNode = SKShapeNode()
        pathNode.position = start
        pathNode.name = "connection"
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: .zero)
        pathToDraw.addLine(to: CGPoint(x: end.x - start.x, y: end.y - start.y))
        pathNode.path = pathToDraw
        pathNode.strokeColor = .green

        return pathNode
    }()
}
