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

    var speed: CGFloat = 10

    var node: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 3)
        node.fillColor = .yellow
        
        return node
    }()

    func pickup(from: Flag, to: Flag) {
        node.run(SKAction.move(to: from.position, duration: self.durationTo(location: from.position))) {
            //get resource
            if let request = from.getNextRequest(for: to) {
                self.deliver(request: request, to: to, from: from)
            }
        }

    }

    func deliver( request: ResourceRouteRequest, to: Flag, from: Flag) {
        node.run(SKAction.move(to: to.position, duration: self.durationTo(location: to.position))) {
            // give resource
            to.receiveRequest(request: request)
            self.currentResourceRequest = nil
             if let request = to.getNextRequest(for: from) {
                 self.deliver(request: request, to: from, from: to)
             } else {
                let midPoint = CGPoint.midPoint(lhs: to.position, rhs: from.position)
                self.returnToWaiting(at: midPoint)

            }
        }
    }

    func returnToWaiting(at location: CGPoint) {
        status = .waiting
        node.run(SKAction.move(to: location, duration: durationTo(location: location)))
    }

    func distanceTo(location: CGPoint) -> CGFloat {
        return node.position.distance(to: location)
    }

    func durationTo(location: CGPoint) -> TimeInterval {
        let distance = distanceTo(location: location)
        return TimeInterval(distance / speed)
    }

}


extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(distanceSquared(to: other))
    }

    func distanceSquared(to other: CGPoint) -> CGFloat {
        let dx = self.x - other.x
        let dy = self.y - other.y
        return (dx * dx) + (dy * dy)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func /=(lhs: inout CGPoint, rhs: CGFloat) {
        lhs.x /= rhs
        lhs.y /= rhs
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }


    static func midPoint(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + ((rhs - lhs) / 2)
    }
}
