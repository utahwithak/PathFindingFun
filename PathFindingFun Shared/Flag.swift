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

    let position: MapPoint
    let playerId: Int

    public private(set) var routes = [Direction: Road]()

    init(at: MapPoint, player: Int) {
        position = at
        playerId = player
        print("Need to handle splitting existing roads")
    }

    var blockingType: BlockingType {
        return .flag
    }

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

    func update(road: Road, from: Direction) {
        routes[from] = road
    }

}

extension Flag: RoadTerminal {

}
