//
//  IcosphereCreator.swift
//  Leaf Press iOS
//
//  Created by Carl Wieland on 1/23/18.
//  Copyright © 2018 Datum Apps. All rights reserved.
//

import Foundation
import SceneKit
import simd

public class IcoSphereCreator
{
    private struct TriangleIndices {
        let v1: Int,v2: Int, v3: Int
    }


    public static func icospherePoints(level: Int, radius: Float = 1, shift: SIMD3<Float> = SIMD3<Float>(0,0,0)) -> [SIMD3<Float>] {
        var positions = [SIMD3<Float>]()
        var middlePointIndexCache = [Int: Int]()

        let addVertex: (_ vert: SIMD3<Float>) -> Int = { vert in

            positions.append((normalize(vert) * radius) + shift)
            return positions.count - 1
        }

        // return index of point in the middle of p1 and p2
        let getMiddlePoint: (Int, Int) -> Int = { p1, p2 in
            // first check if we have it already
            let firstIsSmaller = p1 < p2;
            let smallerIndex = firstIsSmaller ? p1 : p2;
            let greaterIndex = firstIsSmaller ? p2 : p1;
            let key = (smallerIndex << 32) + greaterIndex;


            if let val = middlePointIndexCache[key] {
                return val
            }

            // not in cache, calculate it
            let point1 = positions[p1];
            let point2 = positions[p2];
            let middle = (point1 + point2) / 2

            // add vertex makes sure point is on unit sphere
            let i = addVertex(middle);

            // store it, return index
            middlePointIndexCache[key] = i
            return i;
        }



        // create 12 vertices of a icosahedron
        let t = Float(1.0 + sqrt(5.0)) / 2.0;
        let initial = [SIMD3<Float>(-1,  t,  0),
                     SIMD3<Float>( 1,  t,  0),
                     SIMD3<Float>(-1, -t,  0),
                     SIMD3<Float>( 1, -t,  0),

                     SIMD3<Float>( 0, -1,  t),
                     SIMD3<Float>( 0,  1,  t),
                     SIMD3<Float>( 0, -1, -t),
                     SIMD3<Float>( 0,  1, -t),

                     SIMD3<Float>( t,  0, -1),
                     SIMD3<Float>( t,  0,  1),
                     SIMD3<Float>(-t,  0, -1),
                     SIMD3<Float>(-t,  0,  1)]
        initial.forEach({ _ = addVertex($0)})

        // create 20 triangles of the icosahedron
        var faces = [TriangleIndices(v1: 0, v2: 11, v3: 5),
                     TriangleIndices(v1: 0, v2: 5, v3: 1),
                     TriangleIndices(v1: 0, v2: 1, v3: 7),
                     TriangleIndices(v1: 0, v2: 7, v3: 10),
                     TriangleIndices(v1: 0, v2: 10, v3: 11),

                     // 5 adjacent faces
            TriangleIndices(v1: 1, v2: 5, v3: 9),
            TriangleIndices(v1: 5, v2: 11, v3: 4),
            TriangleIndices(v1: 11, v2: 10, v3: 2),
            TriangleIndices(v1: 10, v2: 7, v3: 6),
            TriangleIndices(v1: 7, v2: 1, v3: 8),

            // 5 faces around point 3
            TriangleIndices(v1: 3, v2: 9, v3: 4),
            TriangleIndices(v1: 3, v2: 4, v3: 2),
            TriangleIndices(v1: 3, v2: 2, v3: 6),
            TriangleIndices(v1: 3, v2: 6, v3: 8),
            TriangleIndices(v1: 3, v2: 8, v3: 9),

            // 5 adjacent faces
            TriangleIndices(v1: 4, v2: 9, v3: 5),
            TriangleIndices(v1: 2, v2: 4, v3: 11),
            TriangleIndices(v1: 6, v2: 2, v3: 10),
            TriangleIndices(v1: 8, v2: 6, v3: 7),
            TriangleIndices(v1: 9, v2: 8, v3: 1)]


        // refine triangles
        for _ in 0..<level {
            var faces2 = [TriangleIndices]();
            for tri in faces {
                // replace triangle by 4 triangles
                let a = getMiddlePoint(tri.v1,tri.v2);
                let b = getMiddlePoint(tri.v2,tri.v3);
                let c = getMiddlePoint(tri.v3,tri.v1);

                faces2.append(TriangleIndices(v1: tri.v1, v2: a, v3: c));
                faces2.append(TriangleIndices(v1: tri.v2, v2: b, v3: a));
                faces2.append(TriangleIndices(v1: tri.v3, v2: c, v3: b));
                faces2.append(TriangleIndices(v1: a, v2: b, v3: c));
            }
            faces = faces2;
        }
        return positions
    }


    public static func create(recursionLevel: Int = 0, radius: Float = 1) -> SCNGeometry {

        var middlePointIndexCache = [Int: Int]()
        var positions = [SIMD3<Float>]()


        let addVertex: (_ vert: SIMD3<Float>) -> Int = { vert in
            positions.append(normalize(vert) * radius)
            return positions.count - 1
        }

        // return index of point in the middle of p1 and p2
        let getMiddlePoint: (Int, Int) -> Int = { p1, p2 in
            // first check if we have it already
            let firstIsSmaller = p1 < p2;
            let smallerIndex = firstIsSmaller ? p1 : p2;
            let greaterIndex = firstIsSmaller ? p2 : p1;
            let key = (smallerIndex << 32) + greaterIndex;


            if let val = middlePointIndexCache[key] {
                return val
            }

            // not in cache, calculate it
            let point1 = positions[p1];
            let point2 = positions[p2];
            let middle = (point1 + point2) / 2

            // add vertex makes sure point is on unit sphere
            let i = addVertex(middle);

            // store it, return index
            middlePointIndexCache[key] = i
            return i;
        }



        // create 12 vertices of a icosahedron
        let t = Float(1.0 + sqrt(5.0)) / 2.0;
        positions = [SIMD3<Float>(-1,  t,  0),
                     SIMD3<Float>( 1,  t,  0),
                     SIMD3<Float>(-1, -t,  0),
                     SIMD3<Float>( 1, -t,  0),

                     SIMD3<Float>( 0, -1,  t),
                     SIMD3<Float>( 0,  1,  t),
                     SIMD3<Float>( 0, -1, -t),
                     SIMD3<Float>( 0,  1, -t),

                     SIMD3<Float>( t,  0, -1),
                     SIMD3<Float>( t,  0,  1),
                     SIMD3<Float>(-t,  0, -1),
                     SIMD3<Float>(-t,  0,  1)]


        // create 20 triangles of the icosahedron
        var faces = [TriangleIndices(v1: 0, v2: 11, v3: 5),
        TriangleIndices(v1: 0, v2: 5, v3: 1),
        TriangleIndices(v1: 0, v2: 1, v3: 7),
        TriangleIndices(v1: 0, v2: 7, v3: 10),
        TriangleIndices(v1: 0, v2: 10, v3: 11),

        // 5 adjacent faces
        TriangleIndices(v1: 1, v2: 5, v3: 9),
        TriangleIndices(v1: 5, v2: 11, v3: 4),
        TriangleIndices(v1: 11, v2: 10, v3: 2),
        TriangleIndices(v1: 10, v2: 7, v3: 6),
        TriangleIndices(v1: 7, v2: 1, v3: 8),

        // 5 faces around point 3
        TriangleIndices(v1: 3, v2: 9, v3: 4),
        TriangleIndices(v1: 3, v2: 4, v3: 2),
        TriangleIndices(v1: 3, v2: 2, v3: 6),
        TriangleIndices(v1: 3, v2: 6, v3: 8),
        TriangleIndices(v1: 3, v2: 8, v3: 9),

        // 5 adjacent faces
        TriangleIndices(v1: 4, v2: 9, v3: 5),
        TriangleIndices(v1: 2, v2: 4, v3: 11),
        TriangleIndices(v1: 6, v2: 2, v3: 10),
        TriangleIndices(v1: 8, v2: 6, v3: 7),
        TriangleIndices(v1: 9, v2: 8, v3: 1)]


        // refine triangles
        for _ in 0..<recursionLevel {
            var faces2 = [TriangleIndices]();
            for tri in faces {
                // replace triangle by 4 triangles
                let a = getMiddlePoint(tri.v1,tri.v2);
                let b = getMiddlePoint(tri.v2,tri.v3);
                let c = getMiddlePoint(tri.v3,tri.v1);

                faces2.append(TriangleIndices(v1: tri.v1, v2: a, v3: c));
                faces2.append(TriangleIndices(v1: tri.v2, v2: b, v3: a));
                faces2.append(TriangleIndices(v1: tri.v3, v2: c, v3: b));
                faces2.append(TriangleIndices(v1: a, v2: b, v3: c));
            }
            faces = faces2;
        }


        var verts = [MeshUtils.GeometryVertex]()
        verts.reserveCapacity(faces.count * 3)
        for tri in faces {
            let normal = IcoSphereCreator.normal(of: positions[tri.v1], b: positions[tri.v2], c: positions[tri.v3])
            verts.append(MeshUtils.GeometryVertex(position: positions[tri.v1], normal: normal))
            verts.append(MeshUtils.GeometryVertex(position: positions[tri.v2], normal: normal))
            verts.append(MeshUtils.GeometryVertex(position: positions[tri.v3], normal: normal))

        }
        let triangles = (0..<verts.count).map { return CInt($0) }

        return MeshUtils.createTriangleGeometry(verts, triangles: triangles)
    }

    static func normal(of a: SIMD3<Float>, b: SIMD3<Float>, c: SIMD3<Float>) -> SIMD3<Float> {
        return normalize(cross(b - a, c - a))
    }
}
