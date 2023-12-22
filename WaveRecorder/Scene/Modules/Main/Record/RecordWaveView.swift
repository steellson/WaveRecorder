//
//  RecordWaveView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 14.12.2023.
//

import Foundation
import UIKit

//MARK: - Impl

final class RecordWaveView: UIView {
    
    var amplitudeValue: CGFloat = 20
    var duration: CGFloat = 20
    var rate: Int = 500
    
    private let sineWaveAnimation = CAKeyframeAnimation()
    private let animationKeyPath = "position"
    private let animationKey = "sine-wave-animaiton"
    
    private var isAnimateNow = false

    
    //MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupShadow()
        setupAnimationSettings()
        setupValues()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(amplitude: CGFloat, duration: CGFloat, rate: Int) {
        self.amplitudeValue = amplitude
        self.duration = duration
        self.rate = rate
    }
 }


//MARK: - Public

extension RecordWaveView {
    
    func start() {
        layer.add(sineWaveAnimation, forKey: animationKey)
        isAnimateNow = true
    }

    func stop() {
        layer.removeAllAnimations()
        isAnimateNow = false
    }
}


//MARK: - Private

private extension RecordWaveView {
    
    func setupView() {
        backgroundColor = .black
        layer.cornerRadius = frame.size.width / 2
    }
    
    func setupShadow() {
        layer.shadowOffset = .init(width: 0.5, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupAnimationSettings() {
        sineWaveAnimation.keyPath = animationKeyPath
        sineWaveAnimation.duration = duration
        sineWaveAnimation.isAdditive = true
    }
    
    func setupValues() {
        if isAnimateNow {
            
            // Need to return view in default position slowly
            
        } else {
            sineWaveAnimation.values = (0..<rate).map({ (x: Int) -> NSValue in
                let xPos = CGFloat(x)
                let yPos = sin(xPos)
                
                let point = CGPoint(x: xPos, y: yPos * amplitudeValue)
                return NSValue(cgPoint: point)
            })
        }
    }
}
