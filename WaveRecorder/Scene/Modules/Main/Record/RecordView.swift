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
    
    private let buttonRadius: CGFloat = 30
    private lazy var recButtonView: RoundedRecButtonView = RoundedRecButtonView(radius: buttonRadius)
        
    
    //MARK: Lifecycle
    
    init(
        viewModel: RecordViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        seutupContentView()
        recButtonView.delegate = self
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
    

    //MARK: Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            recButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recButtonView.heightAnchor.constraint(equalToConstant: buttonRadius * 2),
            recButtonView.widthAnchor.constraint(equalToConstant: buttonRadius * 2),
            recButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}


//MARK: - Presentation Updatable

extension RecordView: PresentationUpdatable {
    func updateView() { }
    func reset() { }
}


//MARK: - RoundedRecButtonView Delegate

extension RecordView: RoundedRecButtonViewDelegate {
    
    func recButtonDidTapped(_ isRecording: Bool) {
        viewModel.record(isRecording: isRecording)
    }
}
