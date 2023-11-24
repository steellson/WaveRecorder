//
//  RecordingView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit

//MARK: - Impl

final class RecordingView: BaseView {
    
    private let buttonRadius: CGFloat = 36.0
    private lazy var recButton = RoundedRecButtonView(radius: buttonRadius)
    
    
    private func seutupContentView() {
        backgroundColor = .white.withAlphaComponent(0.3)
        
        addNewSubview(recButton)
    }
}

//MARK: - Base

extension RecordingView {
    
    override func setupView() {
        super.setupView()
        seutupContentView()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            recButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            recButton.heightAnchor.constraint(equalToConstant: buttonRadius * 2),
            recButton.widthAnchor.constraint(equalToConstant: buttonRadius * 2)
        ])
    }
}
