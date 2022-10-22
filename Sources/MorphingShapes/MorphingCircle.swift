//
//  MorphingCircle.swift
//  Spontanea
//
//  Created by  Alex Dremov on 27.07.2021.
//  Updated by  Michel Löhr on 06.10.22.
//

import SwiftUI
import Foundation

public struct MorphingCircleShape: Shape {
    var pointsNum: Int = 10
    var morphing: AnimatableVector
    var tangentCoeficient: CGFloat
    
    public var animatableData: AnimatableVector {
        get { morphing }
        set { morphing = newValue }
    }
    
    func getTwoTangent(center: CGPoint, point: CGPoint) -> (CGPoint, CGPoint) {
        let a = CGVector(center - point)
        let dir = a.perpendicular() * a.len() * tangentCoeficient
        return (point - dir, point + dir)
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width / 2, rect.height / 2)
        let center =  CGPoint(x: rect.width / 2, y: rect.height / 2)
        var nextPoint = CGPoint.zero
        
        let ithPoint: (Int) -> CGPoint = { i in
            let point = center + CGPoint(x: radius * sin(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)),
                                         y: radius * cos(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)))
            var direction = CGVector(point - center)
            direction = direction / direction.len()
            return point + direction * CGFloat(morphing[i >= pointsNum ? 0 : i])
        }
        var tangentLast = getTwoTangent(center: center,
                                        point: ithPoint(pointsNum - 1))
        for i in (0...pointsNum){
            nextPoint = ithPoint(i)
            let tangentNow = getTwoTangent(center: center, point: nextPoint)
            if i != 0 {
                path.addCurve(to: nextPoint, control1: tangentLast.1, control2: tangentNow.0)
            } else {
                path.move(to: nextPoint)
            }
            tangentLast = tangentNow
        }
        path.closeSubpath()
        return path
    }
    
    
    init(_ morph: AnimatableVector) {
        pointsNum = morph.count
        morphing = morph
        tangentCoeficient = (4 / 3) * tan(CGFloat.pi / CGFloat(2 * pointsNum))
    }
}

public struct MorphingCircle: View & Identifiable & Hashable {
    public static func == (lhs: MorphingCircle, rhs: MorphingCircle) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id = UUID()
    @State var morph: AnimatableVector = AnimatableVector.zero
    @State var timer: Timer?
    
    func morphCreator() -> AnimatableVector {
        let range = Float(-morphingRange)...Float(morphingRange)
        var morphing = Array.init(repeating: Float.zero, count: self.points)
        for i in 0..<morphing.count where Int.random(in: 0...1) == 0 {
            morphing[i] = Float.random(in: range)
        }
        return AnimatableVector(values: morphing)
    }
    
    func update() {
        morph = morphCreator()
    }
    
    let duration: Double
    let points: Int
    let secting: Double
    let size: CGFloat
    let outerSize: CGFloat
    var color: Color
    let morphingRange: CGFloat
    ///
    let outlineColor: Color
    let outlineWidth: Double
    ///
    
    var radius: CGFloat {
        outerSize / 2
    }
    
    public var body: some View {
        MorphingCircleShape(morph)
            // updated with outline
            .fill(color, strokeBorder: outlineColor, lineWidth: outlineWidth)
            .frame(width: size, height: size, alignment: .center)
            .animation(Animation.easeInOut(duration: Double(duration + 1.0)), value: morph)
            .onAppear {
                update()
                timer = Timer.scheduledTimer(withTimeInterval: duration / secting, repeats: true) { timer in
                    update()
                }
            }.onDisappear {
                timer?.invalidate()
            }
            .frame(width: outerSize, height: outerSize, alignment: .center)
            .animation(nil, value: morph)
        
    }
    
    public init(_ size:CGFloat = 300, morphingRange: CGFloat = 30, color: Color = .red, points: Int = 4,  duration: Double = 5.0, secting: Double = 2, outlineColor: Color = .clear, outlineWidth: Double = 2) {
        self.points = points
        self.color = color
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.morphingRange = morphingRange
        self.duration = duration
        self.secting = secting
        self.size = morphingRange * 2 < size ? size - morphingRange * 2 : 5
        self.outerSize = size
        morph = AnimatableVector(values: [])
        update()
    }
    
    func color(_ newColor: Color) -> MorphingCircle {
        var morphNew = self
        morphNew.color = newColor
        return morphNew
    }
}

struct MorphingCircle_Previews: PreviewProvider {
    static var previews: some View {
        MorphingCircle(outlineColor: .orange, outlineWidth: 10.0)
    }
}
