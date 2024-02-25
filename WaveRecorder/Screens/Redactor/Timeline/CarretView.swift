//
//  CarretView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//


import OSLog
import UIKit

//MARK: - Protocol

protocol CarretViewDelegate: AnyObject {
    
}


//MARK: - Impl

final class CarretView: UIView {
    
    private let backgroundMask = CAShapeLayer()

    
    //MARK: Variables
    
    weak var delegate: CarretViewDelegate?
    
    private var cornerRadiusMultiplier: CGFloat = 0.25
    
    
    //MARK: Draw
    
    override func draw(_ rect: CGRect) {
        setupBackgroundMask(withRect: rect)
    }
    
    
    //MARK: Configure
    
    func configure(withDelegate delegate: CarretViewDelegate) {
        self.delegate = delegate
        
        Task {
            setupView()
            setupPanGesture()
            animateOnAppear()
        }
    }
    
    
    //MARK: Action
    
    @objc
    private func didChangePosition() {
        
    }
}

//MARK: - Setup

private extension CarretView {
    
    func setupView() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }
    
    func setupBackgroundMask(withRect rect: CGRect) {
        self.backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * cornerRadiusMultiplier
        ).cgPath
        self.backgroundMask.backgroundColor = UIColor.white.cgColor
        
        self.backgroundMask.borderWidth = 1
        self.backgroundMask.borderColor = UIColor.black.cgColor
        self.layer.mask = backgroundMask
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(didChangePosition))
        addGestureRecognizer(panGesture)
    }
    
}


//MARK: - Animation

private extension CarretView {
    
    func animateOnAppear() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.backgroundColor = .clear
        } completion: { _ in
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: [.autoreverse]
            ) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backgroundColor = .white
            }
        }
    }
}

