using System;
using Unity;

public class World
{

    private readonly int width, height;
    private MapNode[] mapNodes;

    public World(int width, int height)
    {
        this.width = width;
        this.height = height;
        mapNodes = new MapNode[width * height];

    }

    private void initializeNodes()
    {
        for (int i = 0; i < width * height; i++)
        {
            mapNodes[i].roads = new Road.Types[] { Road.Types.none, Road.Types.none, Road.Types.none };
            mapNodes[i].buildQuality = BuildQuality.nothing;

        }
    }

    public int GetIndex(MapPoint pt)
    {
        return (pt.y * width) + pt.x;
    }

    public ref MapNode GetNodeRef(MapPoint pt)
    {
        return ref mapNodes[GetIndex(pt)];
    }

    public MapNode GetNode(MapPoint pt)
    {
        return mapNodes[GetIndex(pt)];
    }

    public MapObject GetObject(MapPoint pt)
    {
        return GetNode(pt).mapObject;
    }

    public void SetObject(MapPoint pt, MapObject mapObject)
    {
        GetNodeRef(pt).mapObject = mapObject;
    }

    public void SetPointRoad(MapPoint pt, Direction direction, Road.Types type)
    {
        if (Directions.isEastOrSouth(direction))
        {
            SetNodeRoad(pt, Directions.reversed(direction), type);
        }
        else
        {

        }
    }

    private void SetNodeRoad(MapPoint pt, Direction direction, Road.Types type)
    {
        GetNodeRef(pt).roads[(int)direction] = type;
    }

    private bool SetBuildQuality(MapPoint pt, BuildQuality bq)
    {
        BuildQuality oldBQ = GetNode(pt).buildQuality;
        GetNodeRef(pt).buildQuality = bq;
        return oldBQ != bq;
    }

    public int CalcDistance(MapPoint p1, MapPoint p2)
    {
        int dx = ((p1.x - p2.x) * 2) + (p1.y & 1) - (p2.y & 1);
        int dy = ((p1.y > p2.y) ? p1.y - p2.y : p2.y - p1.y) * 2;

        if (dx < 0)
            dx = -dx;

        if (dy > height)
        {
            dy = (height * 2) - dy;
        }

        if (dx > width)
        {
            dx = (width * 2) - dx;
        }

        dx -= dy / 2;

        return ((dy + (dx > 0 ? dx : 0)) / 2);
    }

    public MapPoint GetNeighbor(MapPoint pt, Direction direction)
    {
        /*  Note that every 2nd row is shifted by half a triangle to the left, therefore:
           Modifications for the dirs:
           current row:    Even    Odd
                        W  -1|0   -1|0
           D           NW  -1|-1   0|-1
           I           NE   0|-1   1|-1
           R            E   1|0    1|0
                       SE   0|1    1|1
                       SW  -1|1    0|1
        */

        int x;
        int y;
        switch (direction)
        {
            case Direction.west: // -1|0   -1|0
                x = ((pt.x == 0) ? width : pt.x) - 1;
                y = pt.y;
                break;
            case Direction.northwest: // -1|-1   0|-1
                x = (pt.y & 1) != 0 ? pt.x : (((pt.x == 0) ? width : pt.x) - 1);
                y = ((pt.y == 0) ? height : pt.y) - 1;
                break;
            case Direction.northeast: // 0|-1  -1|-1
                x = (!((pt.y & 1) != 0)) ? pt.x : ((pt.x == width - 1) ? 0 : pt.x + 1);
                y = ((pt.y == 0) ? height : pt.y) - 1;
                break;
            case Direction.east: // 1|0    1|0
                x = pt.x + 1;
                if (x == width)
                    x = 0;
                y = pt.y;
                break;
            case Direction.southeast: // 1|1    0|1
                x = (!((pt.y & 1) != 0)) ? pt.x : ((pt.x == width - 1) ? 0 : pt.x + 1);
                y = pt.y + 1;
                if (y == height)
                    y = 0;
                break;
            default: // 0|1   -1|1
                x = (pt.y & 1) != 0 ? pt.x : (((pt.x == 0) ? width : pt.x) - 1); //-V537
                y = pt.y + 1;
                if (y == height)
                    y = 0;
                break;
        }


        return new MapPoint((ushort)x, (ushort)y);
    }

    public MapPoint GetSecondNeighbor(MapPoint pt, int direction)
    {
        int ptx = (int)pt.x;
        int pty = (int)pt.y;


        int[] yShift = { 0, -1, -2, -2, -2, -1, 0, 1, 2, 2, 2, 1 };

        switch (direction)
        {
            case 0:
                ptx -= 2; break;
            case 1:
                ptx -= 2 - (((pt.y & 1) != 0) ? 1 : 0); break;
            case 2:
                ptx -= 1; break;
            case 3: break;
            case 4:
                ptx += 1; break;
            case 5:
                ptx += 2 - (((pt.y & 1) != 0) ? 0 : 1); break;
            case 6:
                ptx += 2; break;
            case 7:
                ptx += 2 - (((pt.y & 1) != 0) ? 0 : 1); break;
            case 8:
                ptx += 1; break;
            case 9: break;
            case 10: ptx -= 1; break;
            default:
                ptx -= 2 - (((pt.y & 1) != 0) ? 1 : 0); break;
        }

        pty += yShift[direction];

        if (direction > 3 && direction < 9)
        {
            ptx %= width;
        }

        if (direction > 6)
        {
            pty %= height;
        }

        if (ptx < 0)
        {
            ptx += width;
        }

        if (pty < 0)
        {
            pty += height;
        }
        return new MapPoint(ptx, pty);

    }

    public BuildQuality GetBuildQuality(MapPoint pt, int player)
    {
        BuildQuality nodeQuality = GetNode(pt).buildQuality;
        if (nodeQuality == BuildQuality.nothing || !isPlayerTerritory(pt, player))
        {
            return BuildQuality.nothing;
        }

        if (nodeQuality != BuildQuality.flag && !isPlayerTerritory(GetNeighbor(pt, Direction.southeast), player))
        {
            if (GetObject(GetNeighbor(pt, Direction.west))?.blockingType == BlockingType.flag)
            {
                return BuildQuality.nothing;
            }
            if (GetObject(GetNeighbor(pt, Direction.northwest))?.blockingType == BlockingType.flag)
            {
                return BuildQuality.nothing;
            }
            if (GetObject(GetNeighbor(pt, Direction.northeast))?.blockingType == BlockingType.flag)
            {
                return BuildQuality.nothing;
            }

            return BuildQuality.flag;
        }
        else
        {
            return nodeQuality;
        }

    }

    public bool CanBuildRoad(MapPoint pt, bool forBoat)
    {
        if (GetObject(pt)?.blockingType == BlockingType.none)
        {
            return false;
        }

        foreach (Direction dir in Directions.allDirections)
        {
            if (GetObject(GetNeighbor(pt, dir))?.blockingType == BlockingType.nothingAround)
            {
                return false;
            }
            if (HasRoad(pt, dir))
            {
                return false;
            }

        }

        return true;
    }

    public bool HasRoad(MapPoint pt, Direction dir)
    {
        if (Directions.isEastOrSouth(dir))
        {
            return GetRoad(pt, Directions.reversed(dir)) != Road.Types.none;
        }
        else
        {
            return GetRoad(GetNeighbor(pt, dir), dir) != Road.Types.none;
        }
    }

    public Road.Types GetRoad(MapPoint pt, Direction dir)
    {
        return GetNode(pt).roads[(int)dir];
    }

    public bool isPlayerTerritory(MapPoint pt, int player)
    {
        return true;
    }

    public bool IsOnRoad(MapPoint pt)
    {
        foreach(Direction roadDir in Directions.westNorth) {
            if (HasRoad(pt, roadDir) || HasRoad(GetNeighbor(pt, roadDir), roadDir)) {
                return true;
            }
        }


        return false;
    }

    public void RecalcBuildQualityForRoad(MapPoint pt)
    {
        RecalcBuildQuality(pt);
        RecalcBuildQuality(GetNeighbor(pt, Direction.east));
        RecalcBuildQuality(GetNeighbor(pt, Direction.southeast));
        RecalcBuildQuality(GetNeighbor(pt, Direction.southwest));

    }

    public void RecalcBuildQualityAround(MapPoint pt, bool extended = false)
    {
        RecalcBuildQuality(pt);

        foreach(Direction dir in Directions.allDirections)
        {
            RecalcBuildQuality(GetNeighbor(pt, dir));
        }

        if (extended) {
            for (int i = 0; i < 12; ++i)
            {
                RecalcBuildQuality(GetSecondNeighbor(pt, i));
            }
        }
        
    }


    public void RecalcBuildQuality(MapPoint pt)
    {
        BuildQualityCalculator calculator = new BuildQualityCalculator(this);
        if (SetBuildQuality(pt, calculator.GetBuildQuality(pt))) {
            UnityEngine.Debug.Log("Notify BQ Change!");
        }
    }

    public bool IsFlagAround(MapPoint pt) {
        foreach(Direction dir in Directions.allDirections) {
            if (GetObject(GetNeighbor(pt, dir))?.blockingType == BlockingType.flag) {
                return true;
            }
        }
        return false;
    }


    public void PlaceFlag(MapPoint pt, int player, Direction dir)
    {
        if (GetBuildQuality(pt, player) == BuildQuality.nothing) {
            UnityEngine.Debug.Log("Failed to place flag, BQ");
            return;
        }

        if (IsFlagAround(pt))
        {
            UnityEngine.Debug.Log("Failed to place flag, Flag Around");
            return;
        }

        if (GetObject(pt) is Flag)
        {
            UnityEngine.Debug.Log("Failed to place flag, already one there!");
            return;
        }

        SetObject(pt, new Flag(pt, player));
        RecalcBuildQualityAround(pt, true);
        
    }

}
