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
    
    private let recordWaveContainerView = UIView()
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
        addNewSubview(recordWaveContainerView)
        recordWaveContainerView.addNewSubview(recordWaveView)
        
        NSLayoutConstraint.activate([
            recordWaveContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            recordWaveContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            recordWaveContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            recordWaveContainerView.bottomAnchor.constraint(equalTo: recordButtonView.topAnchor, constant: -12),
            
            recordWaveView.centerXAnchor.constraint(equalTo: recordWaveContainerView.centerXAnchor),
            recordWaveView.centerYAnchor.constraint(equalTo: recordWaveContainerView.centerYAnchor),
            recordWaveView.widthAnchor.constraint(equalToConstant: 12),
            recordWaveView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        recordWaveView.configureWith(amplitude: 20, duration: 20, rate: 500)
        recordWaveView.start()
    }
    
    func resetRecordWaveView() {
        recordWaveView.stop()
        recordWaveView.removeFromSuperview()
        recordWaveView.constraints.forEach { $0.isActive = false }
        recordWaveContainerView.removeFromSuperview()
        recordWaveContainerView.constraints.forEach { $0.isActive = false }
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
