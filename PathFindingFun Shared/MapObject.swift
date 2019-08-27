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

    var playerId: Int { get }

    var blockingType: BlockingType { get }

    func node(in world: World) -> SKNode?
}

extension MapObject {
    var playerId: Int {
        return -1
    }
    var blockingType: BlockingType {
        return .none
    }
}

/// How does an object influence other objects/Building quality
enum BlockingType {
    case none           /// Does not block and can be removed
    case flag           /// Is a flag (Block pt and no flags around)
    case building       /// Is a building (Like Single, but special handling in BQ calculation)
    case single         /// Blocks only the point this is on
    case tree           /// Is a tree. Passable by figures but allows only huts around
    case flagsAround    /// Allow only flags around
    case nothingAround  /// Allow nothing around
};
