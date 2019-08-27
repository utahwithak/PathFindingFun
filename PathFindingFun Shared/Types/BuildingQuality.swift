//
//  BuildingQuality.swift
//  PathFindingFun
//
//  Created by Carl Wieland on 8/27/19.
//  Copyright © 2019 Datum Apps. All rights reserved.
//

import Foundation

enum BuildQuality: UInt8
{
    case nothing
    case flag
    case hut
    case house
    case castle
    case mine
    case harbor
}

struct BuildQualityCalculator {
    let world: World

    func buildQuality(for pt: MapPoint, flagOnly: Bool = false) -> BuildQuality {
        // Cannot build on blocking objects
        if let blockType = world.object(at: pt)?.blockingType, blockType != BlockingType.none {
            return .nothing
        }

//        //////////////////////////////////////////////////////////////////////////
//        // 1. Check maximum allowed BQ on terrain
//
//        unsigned building_hits = 0;
//        unsigned mine_hits = 0;
//        unsigned flag_hits = 0;
//
//        const WorldDescription& desc = world.GetDescription();
//        for(unsigned char dir = 0; dir < Direction::COUNT; ++dir)
//        {
//            TerrainBQ bq = desc.get(world.GetRightTerrain(pt, Direction::fromInt(dir))).GetBQ();
//            if(bq == TerrainBQ::CASTLE)
//            ++building_hits;
//            else if(bq == TerrainBQ::MINE)
//            ++mine_hits;
//            else if(bq == TerrainBQ::FLAG)
//            ++flag_hits;
//            else if(bq == TerrainBQ::DANGER)
//            return BQ_NOTHING;
//        }
//
        var curBQ: BuildQuality = .flag
//        if(flag_hits)
//        curBQ = BQ_FLAG;
//        else if(mine_hits == 6)
//        curBQ = BQ_MINE;
//        else if(mine_hits)
//        curBQ = BQ_FLAG;
//        else if(building_hits == 6)
//        curBQ = BQ_CASTLE;
//        else if(building_hits)
//        curBQ = BQ_FLAG;
//        else
//        return BQ_NOTHING;
//
//        RTTR_Assert(curBQ == BQ_FLAG || curBQ == BQ_MINE || curBQ == BQ_CASTLE);

        //////////////////////////////////////////////////////////////////////////
        // 2. Reduce BQ based on altitude

//        unsigned char curAltitude = world.GetNode(pt).altitude;
//        // Restraints for buildings
//        if curBQ == .castle {
//            // First check the height of the (possible) buildings flag
//            // flag point more than 1 higher? -> Flag
//            unsigned char otherAltitude = world.GetNeighbourNode(pt, Direction::SOUTHEAST).altitude;
//            if(otherAltitude > curAltitude + 1)
//            curBQ = BQ_FLAG;
//            else
//            {
//                // Direct neighbours: Flag for altitude diff > 3
//                for(unsigned dir = 0; dir < Direction::COUNT; ++dir)
//                {
//                    otherAltitude = world.GetNeighbourNode(pt, Direction::fromInt(dir)).altitude;
//                    if(safeDiff(curAltitude, otherAltitude) > 3)
//                    {
//                        curBQ = BQ_FLAG;
//                        break;
//                    }
//                }
//
//                if(curBQ == BQ_CASTLE)
//                {
//                    // Radius-2 neighbours: Hut for altitude diff > 2
//                    for(unsigned i = 0; i < 12; ++i)
//                    {
//                        otherAltitude = world.GetNode(world.GetNeighbour2(pt, i)).altitude;
//                        if(safeDiff(curAltitude, otherAltitude) > 2)
//                        {
//                            curBQ = BQ_HUT;
//                            break;
//                        }
//                    }
//                }
//            }
//
//        } else if(curBQ == BQ_MINE && world.GetNeighbourNode(pt, Direction::SOUTHEAST).altitude > curAltitude + 3)
//        {
//            // Mines only possible till altitude diff of 3
//            curBQ = BQ_FLAG;
//        }

        //////////////////////////////////////////////////////////////////////////
        // 3. Check neighbouring objects that make building impossible

        // Blocking manners of neighbours (cache for reuse)
        let neighborBlocks: [BlockingType] = Direction.allDirections.map({ world.object(at: world.neighbor(of: pt, direction: $0))?.blockingType ?? .none })


        if neighborBlocks.contains(.nothingAround) {
            return .nothing
        }

        if flagOnly {

            if neighborBlocks.contains(.flag) {
                return .nothing;
            }

            return .flag
        }

        // Build nothing if we have a flag EAST or SW
        if neighborBlocks[Int(Direction.east.rawValue)] == .flag || neighborBlocks[Int(Direction.southwest.rawValue)] == .flag {
            return .nothing
        }

        //////////////////////////////////////////////////////////////////////////
        // 4. Potentially reduce BQ if some objects are nearby

        // Trees allow only huts and mines around
        if curBQ.rawValue > BuildQuality.hut.rawValue && curBQ != .mine {
            if neighborBlocks.contains(.tree) {
                curBQ = .hut
            }
        }

        // Granite type block (stones, fire, grain fields) -> Flag around
        if neighborBlocks.contains(.flagsAround) {
            curBQ = .flag
        }

        // Castle-sized buildings have extensions -> Need non-blocking object there so it can be removed
        // Note: S2 allowed blocking environment objects here which leads to visual bugs and problems as we can't place the extensions
        if curBQ == .castle {
            for i in 0..<3 {
                if neighborBlocks[i] != .none {
                    curBQ = .house
                }
            }
        }

        // Check for buildings in a range of 2 -> House only
        // Note: This is inconsistent (as in the original) as it allows building a castle then a house, but not the other way round
        // --> Remove this check? Only possible reason why castles could not be build should be the extensions
        if curBQ == .castle {
            for i in 0..<12 {
                let bm = world.object(at: world.secondNeighbor(of: pt, direction: i))?.blockingType ?? .none
                if bm == .building {
                    curBQ = .house
                    break;
                }
            }
        }

        // Road at attachment -> No castle
        if curBQ == .castle {
            for direction in Direction.westNorth {
                if world.isOnRoad(at: world.neighbor(of: pt, direction: direction)) {
                    curBQ = .house;
                    break;
                }
            }
        }

        // If point is on a road -> Flag only
        if curBQ != .flag && world.isOnRoad(at: pt) {
            curBQ = .flag
        }

        if curBQ == .flag {
            // If any neighbour is a flag -> Flag is impossible
            if neighborBlocks.contains(.flag) {
                return .nothing
            }
            return .flag
        }

//        // If we can build a castle and this is a harbor point -> Allow harbor
//        if(curBQ == BQ_CASTLE && world.GetNode(pt).harborId) {
//            curBQ = BQ_HARBOR;
//        }

        //////////////////////////////////////////////////////////////////////////
        ///At this point we can still build a building/mine

        // If there is a flag where the house flag would be -> OK
        if neighborBlocks[4] == .flag {
            return curBQ;
        }

        // If we can build the house flag -> OK
        if buildQuality(for: world.neighbor(of: pt, direction: .southeast), flagOnly: true) != .nothing {
            return curBQ;
        }

        // If not, we could still build a flag, unless there is another one around
        if (neighborBlocks[0..<3]).contains(.flag) {
            return .nothing
        }

        return .flag;
    }

}
