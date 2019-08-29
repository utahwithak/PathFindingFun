using System;
using System.Collections.Generic;

public struct BuildQualityCalculator
{
    readonly World world;

    public BuildQualityCalculator(World world)
    {
        this.world = world;
    }

    public BuildQuality GetBuildQuality(MapPoint pt, bool flagOnly = false)
    {
        // Cannot build on blocking objects
        if (world.GetObject(pt)?.blockingType != BlockingType.none)
        {
            return BuildQuality.nothing;
        }

        BuildQuality curBQ = BuildQuality.flag;
        //////////////////////////////////////////////////////////////////////////
        // 3. Check neighbouring objects that make building impossible

        // Blocking manners of neighbours (cache for reuse)
        List<BlockingType> neighborBlocks = new List<BlockingType>();

        foreach (Direction dir in Directions.allDirections)
        {
            neighborBlocks.Add(world.GetObject(world.GetNeighbor(pt, dir))?.blockingType ?? BlockingType.none);
        }


        if (neighborBlocks.Contains(BlockingType.nothingAround))
        {
            return BuildQuality.nothing;
        }

        if (flagOnly)
        {

            if (neighborBlocks.Contains(BlockingType.flag))
            {
                return BuildQuality.nothing;
            }

            return BuildQuality.flag;
        }

        // Build nothing if we have a flag EAST or SW
        if (neighborBlocks[(int)Direction.east] == BlockingType.flag || neighborBlocks[(int)Direction.southwest] == BlockingType.flag)
        {
            return BuildQuality.nothing;
        }

        //////////////////////////////////////////////////////////////////////////
        // 4. Potentially reduce BQ if some objects are nearby

        // Trees allow only huts and mines around
        if ((int)curBQ > (int)BuildQuality.hut && curBQ != BuildQuality.mine)
        {
            if (neighborBlocks.Contains(BlockingType.tree))
            {
                curBQ = BuildQuality.hut;
            }
        }

        // Granite type block (stones, fire, grain fields) -> Flag around
        if (neighborBlocks.Contains(BlockingType.flagsAround))
        {
            curBQ = BuildQuality.flag;
        }

        // Castle-sized buildings have extensions -> Need non-blocking object there so it can be removed
        // Note: S2 allowed blocking environment objects here which leads to visual bugs and problems as we can't place the extensions
        if (curBQ == BuildQuality.castle)
        {

            if (neighborBlocks[0] != BlockingType.none || neighborBlocks[1] != BlockingType.none || neighborBlocks[2] != BlockingType.none)
            {
                curBQ = BuildQuality.house;
            }
        }


        // Check for buildings in a range of 2 -> House only
        // Note: This is inconsistent (as in the original) as it allows building a castle then a house, but not the other way round
        // --> Remove this check? Only possible reason why castles could not be build should be the extensions
        if (curBQ == BuildQuality.castle)
        {
            for (int i = 0; i < 12; i++)
            {
                BlockingType surroundingType = (world.GetObject(world.GetSecondNeighbor(pt, i)))?.blockingType ?? BlockingType.none;
                if (surroundingType == BlockingType.building)
                {
                    curBQ = BuildQuality.house;
                    break;
                }
            }
        }

        // Road at attachment -> No castle
        if (curBQ == BuildQuality.castle)
        {

            if (world.IsOnRoad(world.GetNeighbor(pt, Direction.west))
                || world.IsOnRoad(world.GetNeighbor(pt, Direction.northeast))
                || world.IsOnRoad(world.GetNeighbor(pt, Direction.northwest)))
            {

                curBQ = BuildQuality.house;
            }

        }

        // If point is on a road -> Flag only
        if (curBQ != BuildQuality.flag && world.IsOnRoad(pt))
        {
            curBQ = BuildQuality.flag;
        }

        if (curBQ == BuildQuality.flag)
        {
            // If any neighbour is a flag -> Flag is impossible
            if (neighborBlocks.Contains(BlockingType.flag))
            {
                return BuildQuality.nothing;
            }
            return BuildQuality.flag;
        }

        //        // If we can build a castle and this is a harbor point -> Allow harbor
        //        if(curBQ == BQ_CASTLE && world.GetNode(pt).harborId) {
        //            curBQ = BQ_HARBOR;
        //        }

        //////////////////////////////////////////////////////////////////////////
        ///At this point we can still build a building/mine

        // If there is a flag where the house flag would be -> OK
        if (neighborBlocks[4] == BlockingType.flag)
        {
            return curBQ;
        }

        // If we can build the house flag -> OK
        if (GetBuildQuality(world.GetNeighbor(pt, Direction.southeast), true) != BuildQuality.nothing)
        {
            return curBQ;
        }

        // If not, we could still build a flag, unless there is another one around
        if (neighborBlocks.GetRange(0, 3).Contains(BlockingType.flag))
        {
            return BuildQuality.nothing;
        }

        return curBQ;
    }
}
