//
//  VectorAnimation.swift
//  Spontanea
//
//  Created by  Alex Dremov on 27.07.2021.
//


// https://gist.github.com/mecid/18a80b18cc9670eef1d8667cf8c886bd
import SwiftUI
import enum Accelerate.vDSP

public struct AnimatableVector: VectorArithmetic {
    public static var zero = AnimatableVector(values: [0.0])

    public static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.add(lhs.values[0..<count], rhs.values[0..<count]))
    }

    public static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    public static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count]))
    }

    public static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    var values: [Float]

    mutating public func scale(by rhs: Double) {
        vDSP.multiply(Float(rhs), values, result: &values)
    }

    public var magnitudeSquared: Double {
        Double(vDSP.sum(vDSP.multiply(values, values)))
    }
    
    var count: Int {
        values.count
    }
    
    subscript(_ i: Int) -> Float {
        get {
            values[i]
        } set {
            values[i] = newValue
        }
    }
}
