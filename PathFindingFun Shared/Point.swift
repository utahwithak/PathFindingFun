//
//  Point.swift
//  PathFindingFun iOS
//
//  Created by Carl Wieland on 8/26/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation


struct Point<T: Numeric>: Equatable {
    var x: T
    var y: T

    init() {
        x = T(exactly: 0)!
        y = T(exactly: 0)!
    }

    init(x: T, y: T) {
        self.x = x
        self.y = y
    }
    init(_ x: T, _ y: T) {
        self.x = x
        self.y = y
    }
  
}
