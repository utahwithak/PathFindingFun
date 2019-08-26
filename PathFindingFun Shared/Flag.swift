//
//  Flag.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

class Flag: MapObject {

    static let settings = TransportationSettings()
    static var maxResourcesPerFlag = 4


    init(at: MapPoint) {
        position = at

    }
    
    var roads = [Road]()

    var position: MapPoint


    private lazy var node: SKNode = {
        let flagNode = SKNode()

        let top = SKSpriteNode(imageNamed: "flagTop")
        top.anchorPoint = CGPoint(x: 0, y: 0)
        flagNode.addChild(top)

        let pole = SKSpriteNode(imageNamed: "pole")
        pole.anchorPoint = CGPoint(x: 0, y: 0)
        flagNode.addChild(pole)
        

        flagNode.zPosition = 1
        flagNode.setScale(0.2)
        return flagNode
    }()

    func node(in world: World) -> SKNode? {
        let node = self.node
        node.position = world.position(of: position)
        return node
    }

}
