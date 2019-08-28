using System;


public class Road: MapObject
{
    public enum Types { none, regular };

    public BlockingType blockingType {
        get
        {
            return BlockingType.none;
        }
    }
}
