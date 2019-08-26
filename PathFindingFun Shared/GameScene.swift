//
//  GameScene.swift
//  PathFindingFun Shared
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let pathFinder = PathFinder()

    let pathNode = SKNode()
    let worldNode = SKNode()

    var selectedPoint: MapPoint?

    let world = World(width: 16, height: 16)

    fileprivate var currentlySelectedFlag: Flag?

    fileprivate var currentConnection: SKShapeNode?
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func setUpScene() {
        pathNode.zPosition = 5
        scene?.addChild(pathNode)
        scene?.addChild(worldNode)

        for x in 0..<world.width {
            for y in 0..<world.height {
                let coord = MapPoint(x: x, y: y)
                let node = SKShapeNode(circleOfRadius: 4)
                node.fillColor = .brown
                node.position = world.position(of: coord)
                worldNode.addChild(node)


            }
        }
        let position = world.position(of: MapPoint(world.width, world.height))
        worldNode.position -= position / 2

//        var prevRowNodes: [Flag]?

//        var allFlags = [Flag]()
//        for x in 0..<10 {
//            var prevFlag: Flag?
//            var rowNodes = [Flag]()
//
//            for y in 0..<10 {
//                let flag = pathFinder.addFlag(at:  CGPoint(x: x * 40, y: y * 40))
//
//                allFlags.append(flag)
//
//                addChild(flag.node)
//                if let prev = prevFlag {
//                    let road = pathFinder.addRoad(from: prev, to: flag)
//                    if let roadNode = road.node {
//                        addChild(roadNode)
//                    }
//                    addChild(road.worker.node)
//                    road.worker.node.position = road.midPoint
//                }
//                if let prevs = prevRowNodes {
//                    let road = pathFinder.addRoad(from: prevs[y], to: flag)
//                    if let roadNode = road.node {
//                        addChild(roadNode)
//                    }
//                    addChild(road.worker.node)
//                    road.worker.node.position = road.midPoint
//                }
//                rowNodes.append(flag)
//                prevFlag = flag
//            }
//            prevFlag = nil
//            prevRowNodes = rowNodes
//
//        }
//        for item in 0..<15 {
//            let randomStart = allFlags.shuffled()[0]
//            let randomStop = allFlags.shuffled()[0]
//            let path = PathFinder.findPath(from: randomStart, to: randomStop)
//            let resourceRequest = ResourceRouteRequest(resource: .wood, path: path)
//            randomStart.receiveRequest(request: resourceRequest)
//        }


    }

    func createFlag(at pt: MapPoint) -> Flag {
        let flag = Flag(at: pt)
        if let node = flag.node(in: world) {
            worldNode.addChild(node)
        }
        world.setObject(flag, at: pt)
        return flag

    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {

    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func rightMouseDown(with event: NSEvent) {

    }
    override func rightMouseUp(with event: NSEvent) {

    }

    override func mouseDown(with event: NSEvent) {

        var nearestX = CGFloat.greatestFiniteMagnitude
        var nearestY = CGFloat.greatestFiniteMagnitude
        let location = event.location(in: worldNode)
        var selectionX = 0
        var selectionY = 0
        for y in 0..<world.height {
            let position = world.position(of: MapPoint(0, y))
            let dist = abs(position.y - location.y)
            if dist < nearestY {
                nearestY = dist
                selectionY = y
            } else {
                break
            }
        }
        for x in 0..<world.width {
            let position = world.position(of: MapPoint(x, selectionY))
            let dist = abs(position.x - location.x)
            if dist < nearestX {
                nearestX = dist
                selectionX = x
            } else {
                break
            }
        }

        print("Nearest location:\(selectionX),\(selectionY)")

        let selection = MapPoint(selectionX, selectionY)
        if let currentSelection = selectedPoint {
            if currentSelection == selection {
                if let flag = world.object(at: currentSelection) {
                    currentlySelectedFlag = flag as? Flag
                } else {
                    currentlySelectedFlag = createFlag(at: currentSelection)
                }

            }
        } else {
            selectedPoint = selection
        }

    }



}
#endif

