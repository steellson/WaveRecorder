//
//  RecordView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit

//MARK: - Protocol

protocol RecordViewDelegate: AnyObject {
    func recordStarted()
    func recordFinished()
}


//MARK: - Impl

final class RecordView: BaseView {
    
    weak var delegate: RecordViewDelegate?
        
    private let viewModel: RecordViewModelProtocol
    
    private lazy var recButtonView = RoundedRecButtonView(radius: viewModel.buttonRadius)

    
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
        backgroundColor = R.Colors.primaryBackgroundColor
        addNewSubview(recButtonView)
    }
    
    private func setupRecButtonView() {
        recButtonView.delegate = self
    }
}


//MARK: - Base

extension RecordView {
    
    override func setupView() {
        super.setupView()
        seutupContentView()
        setupRecButtonView()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            recButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recButtonView.heightAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2),
            recButtonView.widthAnchor.constraint(equalToConstant: viewModel.buttonRadius * 2),
            recButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}


//MARK: - RoundedRecButtonView Delegate

extension RecordView: RoundedRecButtonViewDelegate {
    
    func recButtonDidTapped() {
        if recButtonView.isRecording {
            viewModel.startRecord()
            delegate?.recordStarted()
        } else {
            viewModel.stopRecord(completion: nil)
            delegate?.recordFinished()
        }
    }
}
