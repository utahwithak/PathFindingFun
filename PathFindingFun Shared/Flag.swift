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

    static let settings = TransportationSettings()
    static var maxResourcesPerFlag = 4

    private static var flagNum = 1

    let num: Int

    init(at: CGPoint) {
        position = at
        num = Flag.flagNum
        Flag.flagNum += 1
    }
    
    var roads = [Road]()
    var position: CGPoint

    var resourceRequests = [ResourceRouteRequest]()

    func canAcceptRequest() -> Bool {
        return resourceRequests.count < Flag.maxResourcesPerFlag
    }

    var connectedFlags: [Flag] {
        return roads.compactMap({ $0.f1 == self ? $0.f2 : $0.f1 })
    }


    func receiveRequest(request: ResourceRouteRequest) {
        print("Received request")
        if request.goal == self {
            print("Reached final")

        } else if let nextFlag = request.nextFlag(after: self), let road = road(to: nextFlag) {
            resourceRequests.append(request)
            if road.worker.status == .waiting {
                road.requestWorker(to: self)
            }
        }
    }

    func road(to flag: Flag) -> Road? {
        return roads.first(where: {
            ($0.f1 == self && $0.f2 == flag) || ($0.f2 == self && $0.f1 == flag)
        })
    }

    func getNextRequest(for flag: Flag) -> ResourceRouteRequest? {
         let request = resourceRequests.filter({$0.nextFlag(after: self) == flag }).sorted(by: Flag.settings.sorter).first

        if let request = request, let firstIndex = resourceRequests.firstIndex(where: { $0.resource == request.resource && $0.goal == request.goal }) {
            resourceRequests.remove(at: firstIndex)
        }

        return request
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
