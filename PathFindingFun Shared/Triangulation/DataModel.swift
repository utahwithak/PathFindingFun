//
//  DataModel.swift
//  ConvexHull
//
//  Created by Carl Wieland on 1/18/18.
/******************************************************************************
 *
 * The MIT License (MIT)
 *
 * MIConvexHull, Copyright (c) 2015 David Sehnal, Matthew Campbell
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *****************************************************************************/

import Foundation

internal struct DeferredFace {
    /// The faces.
    let face: Int
    let pivot: Int
    let oldFace: Int

    /// The indices.
    let faceIndex: Int
    let pivotIndex: Int
}

/// A helper class used to connect faces.
internal struct FaceConnector: Equatable, Hashable {

    /// The edge to be connected.
    let edgeIndex: Int

    /// The face.
    let face: Int

    /// The vertex indices.
    let v0: Int
    let v1: Int

    init(face: ConvexFaceInternal, edgeIndex: Int) {
        self.face = face.index;
        self.edgeIndex = edgeIndex;

        switch edgeIndex {
        case 0:
            v0 = face.vert1
            v1 = face.vert2
        case 1:
            v0 = face.vert0
            v1 = face.vert2
        default:
            v0 = face.vert0
            v1 = face.vert1
        }

    }

    static func ==(lhs: FaceConnector, rhs: FaceConnector) -> Bool {
        return lhs.v0 == rhs.v0 && lhs.v1 == rhs.v1
    }
    func hash(into hasher: inout Hasher) {
        v0.hash(into: &hasher)
        v1.hash(into: &hasher)
    }

}


/// This internal class manages the faces of the convex hull. It is a
/// separate class from the desired user class.
struct ConvexFaceInternal {
    /// Gets or sets the adjacent face data.
    public var adj0 = 0
    public var adj1 = 0
    public var adj2 = 0

    mutating func set(adj: Int, to: Int) {
        switch adj {
        case 0:
            adj0 = to
        case 1:
            adj1 = to
        default:
            adj2 = to
        }
    }

    /// The furthest vertex.
    public var furthestVertex = 0

    /// Index of the face inside the pool.
    public let index: Int

    /// Is the normal flipped?
    public var isNormalFlipped = false

    /// Gets or sets the normal vector.
    public var normal = Vector3.zero

    /// Face plane constant element.
    public var offset: Double = 0

    /// Gets or sets the vertices.
    public var vert0 = 0
    public var vert1 = 0
    public var vert2 = 0

    /// Gets or sets the vertices beyond.
    public var verticesBeyond = [Int]()

    public init(index: Int) {
        self.index = index
    }

    mutating func reset() {
        adj0 = -1
        adj1 = -1
        adj2 = -1
    }

    subscript (index: Int) -> Int {
        get {
            return index == 0 ? vert0 : (index == 1 ? vert1 : vert2)
        }
        set {
            switch index {
            case 0:
                vert0 = newValue
            case 1:
                vert1 = newValue
            default:
                vert2 = newValue
            }
        }
    }
}
