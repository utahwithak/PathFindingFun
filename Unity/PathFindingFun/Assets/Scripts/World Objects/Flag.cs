using System;
public class Flag: MapObject
{

    MapPoint position;
    int playerID;

    public Flag(MapPoint pt, int player)
    {
        position = pt;
        playerID = player;

    }


    public BlockingType blockingType
    {
        get
        {
            return BlockingType.flag;
        }
    }
}
