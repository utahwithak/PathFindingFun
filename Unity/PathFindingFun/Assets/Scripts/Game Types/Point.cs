﻿using System;


public struct Point<T> : IEquatable<Point<T>>
{
    public readonly T x;
    public readonly T y;

    public Point(T x, T y)
    {
        this.x = x;
        this.y = y;
    }

    public bool Equals(Point<T> other)
    {

        return true;
    }

    public override bool Equals(object obj)
    {
        Point<T>? pointObject = obj as Point<T>?;
        if (pointObject.HasValue)
        {
            return Equals(pointObject.Value);
        }
        else
        {
            return false;
        }

    }

    public override int GetHashCode()
    {
        return (x.GetHashCode() * 37) ^ (y.GetHashCode() * 23) ^ base.GetHashCode();
    }
}