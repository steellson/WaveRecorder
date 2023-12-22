//
//  RecordButtonView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import UIKit


//MARK: - Protocol

protocol RecordButtonViewDelegate: AnyObject {
    func recButtonDidTapped(_ isRecording: Bool)
}


//MARK: - Impl

final class RecordButtonView: UIView {
    
    weak var delegate: RecordButtonViewDelegate?
    
    //MARK: Variables
    
    private let radius: CGFloat
    
    private let button = UIButton()
    private let roundedLayer = CAShapeLayer()
    
    private var isRecording = false {
        didSet {
            animateRecordButton(isRecording)
        }
    }
    
    
    //MARK: - Lifecycle
    
    init(
        radius: CGFloat
    ) {
        self.radius = radius
        super.init(frame: .zero)
        
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupButtonAppearence()
        setupRoundedLayer()
        setupConstraints()
    }
        
    
    
    
    //MARK: - Methods
    
    private func animateRecordButton(_ isRecording: Bool) {
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
    
    
    //MARK: Actions
    
    @objc private func buttonDidTapped() {
        delegate?.recButtonDidTapped(isRecording)
        isRecording.toggle()
    }
}


//MARK: - Setup

private extension RecordButtonView {
    
    func setupContentView() {
        backgroundColor = .clear
        addNewSubview(button)
    }
    
    func setupButtonAppearence() {
        button.backgroundColor = .red
        button.layer.cornerRadius = radius
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    func setupRoundedLayer() {
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
    

    //MARK: Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.95),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
