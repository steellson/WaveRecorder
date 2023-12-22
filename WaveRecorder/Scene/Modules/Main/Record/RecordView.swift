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
    
    private let recordWaveView = RecordWaveView()
    
    private let buttonRadius: CGFloat = 30
    private lazy var recordButtonView: RecordButtonView = RecordButtonView(radius: buttonRadius)
        
    
    //MARK: Lifecycle
    
    init(
        viewModel: RecordViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        seutupContentView()
        recordButtonView.delegate = self
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
        addNewSubview(recordButtonView)
    }
    
    func setupRecordWaveView() {
        recordWaveView.configureWith(direction: .right, speed: 20)
        recordWaveView.clipsToBounds = true
        addNewSubview(recordWaveView)
        
        NSLayoutConstraint.activate([
            recordWaveView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            recordWaveView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            recordWaveView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            recordWaveView.bottomAnchor.constraint(equalTo: recordButtonView.topAnchor, constant: -32)
        ])
        
        recordWaveView.animationStart()
    }
    
    func resetRecordWaveView() {
        recordWaveView.animationStop()
        recordWaveView.constraints.forEach { $0.isActive = false }
        recordWaveView.removeFromSuperview()
    }


    //MARK: Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            recordButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButtonView.heightAnchor.constraint(equalToConstant: buttonRadius * 2),
            recordButtonView.widthAnchor.constraint(equalToConstant: buttonRadius * 2),
            recordButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}


//MARK: - Presentation Updatable

extension RecordView: PresentationUpdatable { }


//MARK: - RoundedRecButtonView Delegate

extension RecordView: RecordButtonViewDelegate {
    
    func recButtonDidTapped(_ isRecording: Bool) {
        viewModel.record(isRecording: isRecording)
        
        if !isRecording {
            setupRecordWaveView()
        } else {
             resetRecordWaveView()
        }
        
        layoutIfNeeded()
    }
}
