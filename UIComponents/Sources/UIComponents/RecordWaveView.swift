//
//  ReordWaveView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 22.12.2023.
//

import Foundation
import UIKit


//MARK: - Impl

final public class RecordWaveView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    
    //MARK: Variables
    
    private var speed = 10.0
    private var frequency = 8.0
    private var parameterA = 1.5
    private var parameterB = 9.0
    private var phase = 0.0
    private var direction: RecordWaveView.Direction = .right
    
    private var color: UIColor = .black
    private var waveWidth: CGFloat = 1
    
    private var startTime: CFTimeInterval = 0
    private weak var displayLink: CADisplayLink?
    
    
    public enum Direction {
        case right
        case left
    }
    
    
    //MARK: Methods
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
                
        let path = UIBezierPath()
        let width = Double(self.frame.width)
        let height = Double(self.frame.height) - 30
        let mid = height * 0.5
        let waveLength = width / frequency
        let waveHeightCoef = Double(frequency)
        
        path.move(to: CGPoint(x: 0, y: self.frame.midY))
        
        for x in stride(from: 0, through: width, by: 1) {
            let actualX = x / waveLength
            let sine = -cos(parameterA*(actualX + phase)) * sin((actualX + phase) / parameterB)
            let y = waveHeightCoef * sine + mid
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
   
        setupShapeLayer(withRect: rect, andPath: path.cgPath)
    }
    
    
    //MARK: Configure
    
    public func configureWith(
        direction: Direction,
        speed: Double,
        waveWidth: CGFloat,
        color: UIColor
    ) {
        self.direction = direction
        self.speed = speed
        self.waveWidth = waveWidth
        self.color = color
    }
    
    public func configureWith(
        speed: Double = 10,
        frequency: Double = 8.0,
        parameterA: Double = 1.5,
        parameterB: Double = 9.0,
        phase: Double = 0.0,
        direction: Direction = .right,
        waveWidth: CGFloat = 1,
        color: UIColor = .black
    ) {
        self.speed = speed
        self.frequency = frequency
        self.parameterA = parameterA
        self.parameterB = parameterA
        self.phase = phase
        self.direction = direction
        self.waveWidth = waveWidth
        self.color = color
    }
                      
    
    //MARK: Setup

    private func setupShapeLayer(withRect rect: CGRect, andPath path: CGPath) {
        shapeLayer.frame = CGRect(
            x: -8,
            y: rect.midY,
            width: rect.width,
            height: rect.height
        )
        shapeLayer.path = path
        shapeLayer.lineWidth = waveWidth
        shapeLayer.fillColor = .none
        shapeLayer.strokeColor = color.cgColor
       
        layer.addSublayer(shapeLayer)
    }
}


//MARK: - Public

public extension RecordWaveView {
    
    func animationStart() {
        speed = direction == .right ? -speed : speed
        startDisplayLink()
    }
    
    func animationStop() {
        stopDisplayLink()
    }
}


//MARK: - Private

private extension RecordWaveView {
    
    func startDisplayLink() {
        self.startTime = CACurrentMediaTime()
        self.displayLink?.invalidate()
        
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        
        self.displayLink = displayLink
    }
    
    func stopDisplayLink() {
        self.displayLink?.remove(from: .main, forMode: .common)
        self.displayLink?.invalidate()
    }
    
    @objc
    func handleDisplayLink(_ displayLink: CADisplayLink) {
        self.phase = (CACurrentMediaTime() - startTime) * speed
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.setNeedsDisplay()
    }
}
