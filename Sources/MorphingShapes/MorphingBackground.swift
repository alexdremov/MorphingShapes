//
//  MorphingBackground.swift
//  Spontanea
//
//  Created by  Alex Dremov on 27.07.2021.
//

import SwiftUI
import Foundation
import Combine

@available(macOS 11.0, *)
struct MorphingBackground: View {
    let number: Int
    let outlay:(x: (left: CGFloat, right: CGFloat),
                y: (up: CGFloat, bottom: CGFloat))
    let duration: Double
    let range: ClosedRange<CGFloat>
    @State var circles: [MorphingCircle] = []
    @State var point: [CGPoint] = []
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading){
                ForEach(Array(circles.enumerated()), id:\.1) { (i, circle) in
                    circles[i]
                        .position(point[i])
                        .animation(.easeInOut(duration: duration), value: point)
                }
            }
            .onReceive(timer, perform: { _ in
                update(proxy)
            })
            .onAppear{
                createCircles()
                update(proxy)
                withAnimation {
                    update(proxy)
                }
            }
        }.ignoresSafeArea()
    }
    
    func update(_ proxy: GeometryProxy){
        point = []
        var newPoints = [CGPoint]()
        for i in 0..<number {
            var minX = 0 + circles[i].radius
            var maxX = proxy.size.width - circles[i].radius
            if maxX < minX {
                circles[i] = MorphingCircle(proxy.size.width / 2, morphingRange: proxy.size.width / 20, color: circles[i].color, points: circles[i].points, duration:  circles[i].duration, secting: circles[i].secting)
                minX = 0 + circles[i].radius
                maxX = proxy.size.width - circles[i].radius
            }
            var minY = 0 + circles[i].radius
            var maxY = proxy.size.height - circles[i].radius
            if maxY < minY {
                circles[i] = MorphingCircle(proxy.size.width / 3, morphingRange: proxy.size.width / 30, color: circles[i].color, points: circles[i].points, duration:  circles[i].duration, secting: circles[i].secting)
                minY = 0 + circles[i].radius
                maxY = proxy.size.height - circles[i].radius
            }
            
            minX -= outlay.x.left
            maxX += outlay.x.right
            
            minY -= outlay.y.up
            maxY += outlay.y.bottom
            
            let delta = CGVector(dx: CGFloat.random(
                                    in: (-proxy.size.width / 5)...(proxy.size.width / 5)),
                                dy: CGFloat.random(
                                    in: (-proxy.size.height / 5)...(proxy.size.height / 5)))
            var newPoint = (point.count > i ?
                                point[i] : CGPoint(x: CGFloat.random(in: minX...maxX),
                                                   y: CGFloat.random(in: minY...maxY)))
                + delta
            
            newPoint.x = newPoint.x < minX ? minX: newPoint.x
            newPoint.y = newPoint.y < minY ? minY: newPoint.y
            
            newPoint.x = newPoint.x > maxX ? maxX: newPoint.x
            newPoint.y = newPoint.y > maxY ? maxY: newPoint.y
            
            newPoints.append(newPoint)
        }
        point = newPoints
    }
    
    func createCircles() {
        circles = []
        point = []
        for _ in 0..<number {
            let circleSize = CGFloat.random(in: range)
            circles.append(MorphingCircle(circleSize, morphingRange: circleSize / 10.0, color: .red))
            point.append(CGPoint.zero)
        }
    }
    
    init(_ number: Int = 5,
         shapeWidth: ClosedRange<CGFloat> = 100...300,
         duration: Double = 30,
         outlay:(x: (left: CGFloat, right: CGFloat),
         y: (up: CGFloat, bottom: CGFloat)) = (x:(0, 0), y:(0, 0))) {
        self.number = number
        self.range = shapeWidth
        self.duration = duration
        self.outlay = outlay
        self.timer = Timer.publish(every: duration / 2, on: .current, in: .common).autoconnect()
    }
}

@available(macOS 11.0, *)
struct MorphingBackground_Previews: PreviewProvider {
    static var previews: some View {
        MorphingBackground()
    }
}
