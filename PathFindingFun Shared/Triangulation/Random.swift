//
//  CwlRandom.swift
//  CwlUtils
//
//  Created by Matt Gallagher on 2016/05/17.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

import SceneKit
//import ConvexHull

public protocol RandomGenerator {

    /// Initializes the provided buffer with randomness
    mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int)

    // Generates 64 bits of randomness
    mutating func random64() -> UInt64

    // Generates 32 bits of randomness
    mutating func random32() -> UInt32

    // Generates a uniform distribution with a maximum value no more than `max`
    mutating func random64(max: UInt64) -> UInt64

    // Generates a uniform distribution with a maximum value no more than `max`
    mutating func random32(max: UInt32) -> UInt32

    /// Generates a double with a random 52 bit significand on the half open range [0, 1)
    mutating func randomHalfOpen() -> Double

    /// Generates a double with a random 52 bit significand on the closed range [0, 1]
    mutating func randomClosed() -> Double

    /// Generates a double with a random 51 bit significand on the open range (0, 1)
    mutating func randomOpen() -> Double
}

public extension RandomGenerator {
    mutating func random64() -> UInt64 {
        var bits: UInt64 = 0
        randomize(buffer: &bits, size: MemoryLayout<UInt64>.size)
        return bits
    }

    mutating func random32() -> UInt32 {
        var bits: UInt32 = 0
        randomize(buffer: &bits, size: MemoryLayout<UInt32>.size)
        return bits
    }

    mutating func random64(max: UInt64) -> UInt64 {
        switch max {
        case UInt64.max: return random64()
        case 0: return 0
        default:
            var result: UInt64
            repeat {
                result = random64()
            } while result < UInt64.max % (max + 1)
            return result % (max + 1)
        }
    }

    mutating func random32(max: UInt32) -> UInt32 {
        switch max {
        case UInt32.max: return random32()
        case 0: return 0
        default:
            var result: UInt32
            repeat {
                result = random32()
            } while result < UInt32.max % (max + 1)
            return result % (max + 1)
        }
    }

    mutating func randomHalfOpen() -> Double {
        return halfOpenDoubleFrom64(bits: random64())
    }

    mutating func randomClosed() -> Double {
        return closedDoubleFrom64(bits: random64())
    }

    mutating func randomOpen() -> Double {
        return openDoubleFrom64(bits: random64())
    }
}

public func halfOpenDoubleFrom64(bits: UInt64) -> Double {
    return Double(bits & 0x001f_ffff_ffff_ffff) * (1.0 / 9007199254740992.0)
}

public func closedDoubleFrom64(bits: UInt64) -> Double {
    return Double(bits & 0x001f_ffff_ffff_ffff) * (1.0 / 9007199254740991.0)
}

public func openDoubleFrom64(bits: UInt64) -> Double {
    return (Double(bits & 0x000f_ffff_ffff_ffff) + 0.5) * (1.0 / 9007199254740991.0)
}

public protocol RandomWordGenerator: RandomGenerator {
    associatedtype WordType
    mutating func randomWord() -> WordType
}

extension RandomWordGenerator {
    public mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        let b = buffer.assumingMemoryBound(to: WordType.self)
        for i in 0..<(size / MemoryLayout<WordType>.size) {
            b[i] = randomWord()
        }
        let remainder = size % MemoryLayout<WordType>.size
        if remainder > 0 {
            var final = randomWord()
            let b2 = buffer.assumingMemoryBound(to: UInt8.self)
            withUnsafePointer(to: &final) { (fin: UnsafePointer<WordType>) in
                fin.withMemoryRebound(to: UInt8.self, capacity: remainder) { f in
                    for i in 0..<remainder {
                        b2[size - i - 1] = f[i]
                    }
                }
            }
        }
    }
}

public struct Xoroshiro: RandomWordGenerator {
    public typealias WordType = UInt64
    public typealias StateType = (UInt64, UInt64)

    var state: StateType = (0, 0)

    public init(seed: StateType) {
        self.state = seed
    }

    public mutating func random64() -> UInt64 {
        return randomWord()
    }

    public mutating func randomWord() -> UInt64 {
        // Directly inspired by public domain implementation here:
        // http://xoroshiro.di.unimi.it
        // by David Blackman and Sebastiano Vigna
        
        let result = state.0 &+ state.1
        let x = state.0 ^ state.1
        state.0 = ((state.0 << 64) | (state.0 >> (64 - 55))) ^ x ^ (x << 14)
        state.1 = (x << 36) | (x >> (64 - 36))
        return result
    }

    public mutating func randomUnit() -> Double {
        let factor = randomClosed()
        return 2 * factor - 1
    }

    public mutating func inUnit() -> Double {
        return randomHalfOpen() * 2 - 1
    }

    public mutating func insideUnitCircle() -> Vector3 {
        return Vector3(inUnit(),inUnit(), 0)
    }

    public mutating func onUnitCircle() -> Vector3 {
        let inside = Vector3(inUnit(),inUnit(), 0)
        return inside / inside.magnitude
    }


    public mutating func insideUnitSphere() -> Vector3 {
        let u = Double(random64())
        var x1 = inUnit() * Double(random64())
        var x2 = inUnit() * Double(random64())
        var x3 = inUnit() * Double(random64())

        let mag = sqrt(x1*x1 + x2*x2 + x3*x3);
        x1 /= mag; x2 /= mag; x3 /= mag;


        let c = pow(u, 1/3)
        return Vector3(x1 * c, x2 * c, x3 * c)
//        var cur = Vector3(inUnit(),inUnit(), inUnit())
//        while cur.magnitudeSquared > 1 {
//            cur = Vector3(inUnit(),inUnit(), inUnit())
//        }
//        return cur
    }

    public mutating func onUnitSphere() -> Vector3 {
        let inside = Vector3(inUnit(), inUnit(), inUnit())
        return inside / inside.magnitude
    }

    public mutating func inside<T:RandRangeConstructable>(range: Range<T>) -> T {
        let min = range.lowerBound
        let max = range.upperBound
        return min + ( max - min) * T(randomHalfOpen())
    }

}

public protocol RandRangeConstructable: Comparable {
    init(_ val: Double)
    static func +(lhs: Self,rhs: Self) -> Self
    static func -(lhs: Self,rhs: Self) -> Self
    static func *(lhs: Self,rhs: Self) -> Self
}

extension Double: RandRangeConstructable {}
extension Int: RandRangeConstructable{}
extension CGFloat: RandRangeConstructable{}
extension Float: RandRangeConstructable{}
