//
//  RoundedRecButton.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import UIKit

//MARK: - Impl

final class RoundedRecButtonView: BaseView {
    
    let radius: CGFloat
    
    private let button = UIButton()

    private let secondaryRoundedLayer = CAShapeLayer()
    
    
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
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    private func setupOverlay() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius + 2,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: false
        )
        
        secondaryRoundedLayer.path = circularPath.cgPath
        secondaryRoundedLayer.strokeColor = UIColor.gray.cgColor
        secondaryRoundedLayer.fillColor = UIColor.clear.cgColor
        secondaryRoundedLayer.lineWidth = 3
        
        layer.addSublayer(secondaryRoundedLayer)
    }
    
    @objc private func buttonDidTapped() {
        print("rec rec rec")
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
        setupOverlay()
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
