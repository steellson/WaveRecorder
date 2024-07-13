//
//  RecordBarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit
import UIComponents
import WRResources

final class RecordBarView: UIView {

    // MARK: - UI
    private let recordVisualizerView = RecordVisualizerView(backgroundColor: WRColors.primaryBackground)
    private let recordWaveView = RecordWaveView()
    private lazy var recordButtonView: RecordButtonView = RecordButtonView(radius: buttonRadius)

    private let buttonRadius: CGFloat = 30
    private let viewModel: RecordBarViewModel

    //MARK: Lifecycle
    init(
        viewModel: RecordBarViewModel
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
        setupRecordButtonViewConstraints()
    }
}

//MARK: - View Output
extension RecordBarView: RecordBarViewProtocol {

    func recordButtonTapped(_ isRecording: Bool) {
        Task {
            try await viewModel.setupRecordAnimated(isRecording)

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

//MARK: - RecordButtonViewDelegate
extension RecordBarView: RecordButtonViewDelegate {

    func recButtonDidTapped(_ isRecording: Bool) {
        recordButtonTapped(isRecording)
    }
}

//MARK: - Setup (Private)
private extension RecordBarView {

    func seutupContentView() {
        backgroundColor = WRColors.primaryBackground
        addNewSubview(recordButtonView)
    }

    func setupRecordVisualizerView() {
        recordVisualizerView.configureWith(
            numbreOfColumns: 20,
            duration: 0.5,
            rate: 0.2,
            color: WRColors.secondaryBackgroundWithLowAlpha
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
            color: WRColors.recoridngWaveLine
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

    func setupRecordButtonViewConstraints() {
        NSLayoutConstraint.activate([
            recordButtonView.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButtonView.heightAnchor.constraint(equalToConstant: buttonRadius * 2),
            recordButtonView.widthAnchor.constraint(equalToConstant: buttonRadius * 2),
            recordButtonView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
}
