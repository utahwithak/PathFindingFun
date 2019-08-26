//
//  MapObject.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation
import SpriteKit

protocol MapObject {

    func node(in world: World) -> SKNode?
}
