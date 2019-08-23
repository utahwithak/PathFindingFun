//
//  TransporationSettings.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/23/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

class TransportationSettings {

    var priorities: [Resource] = Resource.AllCases()
    init() {

    }

    var sorter: ((ResourceRouteRequest, ResourceRouteRequest) -> Bool)  {
        return { [priorities] (lhs, rhs) -> Bool in
            return (priorities.firstIndex(of: lhs.resource) ?? 0) < (priorities.firstIndex(of: rhs.resource) ?? 0)
        }
    }

}
