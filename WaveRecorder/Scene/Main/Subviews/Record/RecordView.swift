//
//  RecordView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit


//MARK: - Impl

final class RecordView: UIView {
    
    private let viewModel: RecordViewModelProtocol
    
    private lazy var recButtonView = RoundedRecButtonView(radius: viewModel.buttonRadius)
    
    var onRecord: ((Bool) -> Void)?
    
    
    //MARK: Lifecycle
    
    init(
        viewModel: RecordViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        seutupContentView()
        setupRecButtonView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
}


//MARK: - Setup

private extension RecordView {
    
    func seutupContentView() {
        backgroundColor = R.Colors.primaryBackgroundColor
        addNewSubview(recButtonView)
    }
    
    func setupRecButtonView() {
        recButtonView.delegate = self
    }
    

    //MARK: Constraints
    
    func setupConstraints() {
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
            onRecord?(recButtonView.isRecording)
        } else {
            viewModel.stopRecord(completion: nil)
            onRecord?(false)
        }
    }
}
