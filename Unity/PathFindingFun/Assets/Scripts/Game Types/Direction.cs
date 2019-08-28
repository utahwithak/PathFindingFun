using System;
using System.Runtime.CompilerServices;


public enum Direction : byte
{
    west,
    northwest,
    northeast,
    east,
    southeast,
    southwest
}

sealed class Directions
{
    private Directions()
    {
    }

    public static readonly Direction[] allDirections = {
    Direction.west,
    Direction.northwest,
    Direction.northeast,
    Direction.east,
    Direction.southeast,
    Direction.southwest
    };

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static Direction reversed(Direction dir)
    {
        switch (dir)
        {
            case Direction.east:
                return Direction.west;
            case Direction.west:
                return Direction.east;
            case Direction.southwest:
                return Direction.northeast;
            case Direction.southeast:
                return Direction.northwest;
            case Direction.northwest:
                return Direction.southeast;
            case Direction.northeast:
                return Direction.southwest;
        }
        return Direction.east;
    }

    static readonly Direction[] westNorth = { Direction.west, Direction.northwest, Direction.northeast };
    static readonly Direction[] eastSouth = { Direction.east, Direction.southeast, Direction.southwest };

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool isEastOrSouth(Direction dir)
    {
        return (int)dir > 2;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool isWestOrNorth(Direction dir)
    {
        return (int)dir < 3;

    }



}

