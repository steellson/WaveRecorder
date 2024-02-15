//
//  RecordBarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit
import UIComponents
import WRResources

//MARK: - Impl

final class RecordBarView: UIView {
    
    private let viewModel: RecordViewModel
    
    private let recordVisualizerView = RecordVisualizerView(backgroundColor: WRColors.primaryBackgroundColor)
    private let recordWaveView = RecordWaveView()
    
    private let buttonRadius: CGFloat = 30
    private lazy var recordButtonView: RecordButtonView = RecordButtonView(radius: buttonRadius)
        
    
    //MARK: Lifecycle
    
    init(
        viewModel: RecordViewModel
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

private extension RecordBarView {
    
    func seutupContentView() {
        backgroundColor = WRColors.primaryBackgroundColor
        addNewSubview(recordButtonView)
    }
    
    func setupRecordVisualizerView() {
        recordVisualizerView.configureWith(
            numbreOfColumns: 20,
            duration: 0.5,
            rate: 0.2,
            color: WRColors.secondaryBackgroundColor.withAlphaComponent(0.3)
        )
        recordVisualizerView.clipsToBounds = true
        addNewSubview(recordVisualizerView)
        
        NSLayoutConstraint.activate([
            recordVisualizerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            recordVisualizerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            recordVisualizerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            recordVisualizerView.bottomAnchor.constraint(equalTo: recordButtonView.topAnchor, constant: -18)
        ])
        
        recordVisualizerView.animationStart()
    }
    
    func setupRecordWaveView() {
        recordWaveView.configureWith(
            direction: .right,
            speed: 20,
            waveWidth: 2,
            color: .systemRed
        )
        recordWaveView.clipsToBounds = true
        addNewSubview(recordWaveView)
        
        NSLayoutConstraint.activate([
            recordWaveView.topAnchor.constraint(equalTo: recordVisualizerView.topAnchor),
            recordWaveView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            recordWaveView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            recordWaveView.bottomAnchor.constraint(equalTo: recordVisualizerView.centerYAnchor, constant: 12)
        ])
        
        recordWaveView.animationStart()
    }
    
    func resetAnimatedViews() {
        recordVisualizerView.animationStop()
        recordVisualizerView.constraints.forEach { $0.isActive = false }
        recordVisualizerView.removeFromSuperview()
        
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


//MARK: - RoundedRecButtonView Delegate

extension RecordBarView: RecordButtonViewDelegate {
    
    func recButtonDidTapped(_ isRecording: Bool) {
        Task {
            try await viewModel.record(isRecording: isRecording)
            
            if !isRecording {
                setupRecordVisualizerView()
                setupRecordWaveView()
            } else {
                resetAnimatedViews()
            }
            
            layoutIfNeeded()
        }
    }
}
