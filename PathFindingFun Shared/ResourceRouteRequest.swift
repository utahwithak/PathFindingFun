//
//  ResourceRouteRequest.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

struct ResourceRouteRequest {
    init(resource: Resource, path: [Flag]) {
        self.resource = resource
        currentPath = path
    }

    let resource: Resource

    var goal: Flag? {
        currentPath.last
    }

    var currentPath: [Flag]

    func nextFlag(after: Flag) -> Flag? {
        if let currentIndex = currentPath.firstIndex(of: after), currentIndex < currentPath.count {
            return currentPath[currentIndex + 1]
        }
        return nil
    }
}
