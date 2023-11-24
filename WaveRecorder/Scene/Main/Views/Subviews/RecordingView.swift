//
//  RecordingView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit

//MARK: - Impl

final class RecordingView: BaseView {
    
    private let viewModel: RecordViewModelProtocol
    
    private lazy var recButton = RoundedRecButtonView(radius: viewModel.buttonRadius)
    
    var onRecord: (() -> Void)?
    
    //MARK: Init
    
    init(
        viewModel: RecordViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Setup
    
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
            recButton.heightAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2),
            recButton.widthAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2)
        ])
    }
}


//MARK: - RoundedRecButtonView Delegate

extension RecordingView: RoundedRecButtonViewDelegate {
    
    func recButtonDidTapped() {
    
        print("tapped")
    }
}
