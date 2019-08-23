//
//  Flag.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

class Flag: Hashable {
    private static var flagNum = 1

    let num: Int

    init(at: CGPoint) {
        position = at
        num = Flag.flagNum
        Flag.flagNum += 1
    }
    
    var roads = [Road]()
    var position: CGPoint

    var connectedFlags: [Flag] {
        return roads.compactMap({ $0.f1 == self ? $0.f2 : $0.f1 })
    }


    lazy var node: SKShapeNode = {
        let newNode = SKShapeNode(circleOfRadius: 10)
        newNode.name = "p\(num)"
        newNode.fillColor = .white
        newNode.zPosition = 1
        newNode.position = position
        return newNode
    }()


    func estimatedCost(to flag: Flag) -> CGFloat {
        return cost(to: flag)
    }

    func cost(to flag: Flag) -> CGFloat {
        let dx = position.x - flag.position.x
        let dy = position.y - flag.position.y
        return (dx * dx) + (dy * dy)
    }

    static func == (lhs: Flag, rhs: Flag) -> Bool {
        lhs.num == rhs.num
    }

    func hash(into hasher: inout Hasher) {
        num.hash(into: &hasher)
    }

}
