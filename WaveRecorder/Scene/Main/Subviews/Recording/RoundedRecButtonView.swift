//
//  RoundedRecButton.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import UIKit

//MARK: - Protocol

protocol RoundedRecButtonViewDelegate: AnyObject {
    func recButtonDidTapped()
}

//MARK: - Impl

final class RoundedRecButtonView: BaseView {
    
    weak var delegate: RoundedRecButtonViewDelegate?
    
    private let radius: CGFloat
    
    private let button = UIButton()
    private let roundedLayer = CAShapeLayer()
    
    private(set) var isRecording = false {
        didSet {
            isRecording 
            ? record(hasStarted: true)
            : record(hasStarted: false)
        }
    }
    
    
    //MARK: - Init
    
    init(
        radius: CGFloat
    ) {
        self.radius = radius
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    //MARK: Setup
    
    private func setupContentView() {
        backgroundColor = .clear
        addNewSubview(button)
    }
    
    private func setupButtonAppearence() {
        button.backgroundColor = .red
        button.layer.cornerRadius = radius
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    private func setupRoundedLayer() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius + 2,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: false
        )
        
        roundedLayer.path = circularPath.cgPath
        roundedLayer.strokeColor = UIColor.gray.cgColor
        roundedLayer.fillColor = UIColor.clear.cgColor
        roundedLayer.lineWidth = 2.5
        
        layer.addSublayer(roundedLayer)
    }
    
    
    //MARK: - Methods
    
    private func record(hasStarted isRecording: Bool) {
        // Tap effect
        UIView.animate(withDuration: 0.2) {
            self.button.alpha = 0.5
        } completion: { _ in
            self.button.alpha = 1
        }
        // Transformation
        UIView.animate(withDuration: 0.3) {
            if isRecording {
                self.button.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                self.button.layer.cornerRadius = self.radius / 3
                self.button.backgroundColor = .systemBlue
            } else {
                self.button.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.button.layer.cornerRadius = self.radius
                self.button.backgroundColor = .red
            }
        }
    }
    
    
    @objc private func buttonDidTapped() {
        isRecording.toggle()
        delegate?.recButtonDidTapped()
    }
}

//MARK: - Base

extension RoundedRecButtonView {
    
    override func setupView() {
        super.setupView()
        setupContentView()
    }
    
    override func setupLayout() {
        super.setupLayout()
        setupButtonAppearence()
        setupRoundedLayer()
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
