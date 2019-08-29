//
//  MeshUtils.swift
//  Leaf Press
//
//  Created by Carl Wieland on 1/11/18.
//  Copyright © 2018 Datum Apps. All rights reserved.
//

import Foundation
import SceneKit
import simd


final class MeshUtils {
    struct GeometryVertex {
        let position: SIMD3<Float>
        let normal: SIMD3<Float>
//        let color: SIMD3<Float>
    }

    public static func geometry(from points: [Vector3], vertColor: SIMD3<Float> = SIMD3<Float>(x: 1, y: 1, z: 1)) -> SCNGeometry {
        let hull = ConvexHull.create(with: points)

        let faces = hull.faces

        var geoVerts = [GeometryVertex]();
        var tris = [CInt]()
        for face in faces {
            guard face.vertices.count == 3 else {
                print("Triangulation failed!?")
                continue
            }
            let normalVert = face.normal
            let normal = SIMD3<Float>(x: Float(normalVert.x), y: Float(normalVert.y), z: Float(normalVert.z))
            let verts = face.vertices
            for vert in verts {
                let geoVert = GeometryVertex(position: SIMD3<Float>(x:Float(vert.x),y: Float(vert.y),z: Float(vert.z)), normal: normal/*, color: vertColor*/)
                tris.append(CInt(tris.count))
                geoVerts.append(geoVert);
            }
        }


        return createTriangleGeometry(geoVerts, triangles: tris)

    }

    public static func triangulate(points: [Vector3], includeHorizontal: Bool = true) -> [GeometryVertex] {
        let hull = ConvexHull.create(with: points)

        let faces = hull.faces

        var geoVerts = [GeometryVertex]();

        for face in faces {
            guard face.vertices.count == 3 else {
                print("Triangulation failed!?")
                continue
            }
            let normalVert = face.normal
            let normal = SIMD3<Float>(x: Float(normalVert.x), y: Float(normalVert.y), z: Float(normalVert.z))

            if !includeHorizontal && abs(normalVert.y) == 1 {
                continue
            }

            let verts = face.vertices
            for vert in verts {
                let geoVert = GeometryVertex(position: SIMD3<Float>(x:Float(vert.x),y: Float(vert.y),z: Float(vert.z)), normal: normal/*, color: vertColor*/)
                geoVerts.append(geoVert);
            }
        }


        return geoVerts

    }

    public static func trunkShell(from points: [Vector3], vertColor: SIMD3<Float> = SIMD3<Float>(x: 1, y: 1, z: 1)) -> SCNGeometry {
        let hull = ConvexHull.create(with: points)

        let faces = hull.faces

        var geoVerts = [GeometryVertex]();
        var tris = [CInt]()
        for face in faces {
            guard face.vertices.count == 3 else {
                print("Triangulation failed!?")
                continue
            }
            let normalVert = face.normal

            if abs(normalVert.y) == 1 {
                continue
            }
            let normal = SIMD3<Float>(x: Float(normalVert.x), y: Float(normalVert.y), z: Float(normalVert.z))
            let verts = face.vertices
            for vert in verts {
                let geoVert = GeometryVertex(position: SIMD3<Float>(x:Float(vert.x),y: Float(vert.y),z: Float(vert.z)), normal: normal/*, color: vertColor*/)
                tris.append(CInt(tris.count))
                geoVerts.append(geoVert);
            }
        }

        return createTriangleGeometry(geoVerts, triangles: tris)

    }

    public static func createTriangleGeometry(_ vertices: [GeometryVertex], triangles: [CInt]) -> SCNGeometry {

        let data = Data(bytes: UnsafeRawPointer(vertices), count: vertices.count * MemoryLayout<GeometryVertex>.size)

        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<GeometryVertex>.size)

        let normalSource = SCNGeometrySource(data: data,
                                             semantic: .normal,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: MemoryLayout<SIMD3<Float>>.size,
                                             dataStride: MemoryLayout<GeometryVertex>.size)


//        let colorSource = SCNGeometrySource(data: data,
//                                            semantic: .color,
//                                            vectorCount: vertices.count,
//                                            usesFloatComponents: true,
//                                            componentsPerVector: 3,
//                                            bytesPerComponent: MemoryLayout<Float>.size,
//                                            dataOffset: (2 * MemoryLayout<SIMD3<Float>>.size),
//                                            dataStride: MemoryLayout<GeometryVertex>.size)

        let triData = Data(bytes: UnsafeRawPointer(triangles), count: MemoryLayout<CInt>.size * triangles.count)

        let geometryElement = SCNGeometryElement(data: triData, primitiveType: .triangles, primitiveCount: triangles.count / 3, bytesPerIndex: MemoryLayout<CInt>.size)

        return SCNGeometry(sources: [vertexSource, normalSource/*, colorSource*/], elements: [geometryElement])
    }

    public static func createTriangleGeometry(ordered vertices: [GeometryVertex]) -> SCNGeometry {

        let data = Data(bytes: UnsafeRawPointer(vertices), count: vertices.count * MemoryLayout<GeometryVertex>.size)

        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<GeometryVertex>.size)

        let normalSource = SCNGeometrySource(data: data,
                                             semantic: .normal,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: MemoryLayout<SIMD3<Float>>.size,
                                             dataStride: MemoryLayout<GeometryVertex>.size)

        let triangles = [CInt](CInt(0)..<CInt(vertices.count))
        let triData = Data(bytes: UnsafeRawPointer(triangles), count: MemoryLayout<CInt>.size * triangles.count)

        let geometryElement = SCNGeometryElement(data: triData, primitiveType: .triangles, primitiveCount: triangles.count / 3, bytesPerIndex: MemoryLayout<CInt>.size)

        return SCNGeometry(sources: [vertexSource, normalSource], elements: [geometryElement])
    }


}
