//
//  Worker.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit


class Worker {

    enum Status {
        case walking
        case waiting
    }

    var status = Worker.Status.waiting
    
    var currentResourceRequest: ResourceRouteRequest?

    var node: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 7)
        node.fillColor = .yellow
        return node
    }()

}
