//
//  PlayToolbarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import OSLog
import UIKit
import UIComponents
import WRResources


//MARK: - Impl

final class PlayToolbarView: UIView {
    
    private var viewModel: PlayToolbarViewModel?
                
    //MARK: Variables
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .darkGray
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.backgroundColor = RColors.secondaryBackgroundColor
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.backgroundColor = RColors.secondaryBackgroundColor
        return label
    }()
    
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let stopButton = PlayTolbarButton(type: .stop)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
        
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupContentView()
        setupConstraints()
        setupSubviewsAnimated()
        setTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureWith(viewModel: PlayToolbarViewModel) {
        self.viewModel = viewModel
        setupSubviewsAnimated()
    }


    
    //MARK: Actions
    
    @objc
    private func toolBarButtonDidTapped(_ sender: PlayTolbarButton) {
        animateTappedButton(withSender: sender)
        setupButtonActions(withSender: sender)
    }
}


//MARK: - Setup

private extension PlayToolbarView {
    
    private func setupContentView() {
        addNewSubview(progressSlider)
        addNewSubview(startTimeLabel)
        addNewSubview(endTimeLabel)
        addNewSubview(goBackButton)
        addNewSubview(playButton)
        addNewSubview(stopButton)
        addNewSubview(goForwardButton)
        addNewSubview(deleteButton)
    }
    
    private func setTargets() {
        goBackButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
    }
    
    private func setupButtonActions(withSender sender: PlayTolbarButton) {
        guard let viewModel else {
            os_log("\(RErrors.playViewModelIsNotSetted)")
            return
        }
        
        do {
            switch sender.type {
            case .goBack: try viewModel.goBack()
            case .goForward: try viewModel.goForward()
            case .delete: try viewModel.deleteRecord()
            case .play: try viewModel.play(
                atTime: progressSlider.value,
                animation: animateProgress
            )
            case .stop:
                try viewModel.stop()
                reset()
            }
        } catch {
            os_log("\(RErrors.playButtonsActionCorrupted)")
            reset()
        }
    }
    
    
    //MARK: Constraints

    func setupConstraints() {
        NSLayoutConstraint.activate([
            progressSlider.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            startTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 12),
            startTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            
            endTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 12),
            endTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            playButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 8),
            playButton.widthAnchor.constraint(equalToConstant: 38),
            playButton.heightAnchor.constraint(equalToConstant: 38),
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -24),
            
            stopButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 8),
            stopButton.widthAnchor.constraint(equalToConstant: 38),
            stopButton.heightAnchor.constraint(equalToConstant: 38),
            stopButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 24),
            
            goBackButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            goBackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -24),
            goBackButton.widthAnchor.constraint(equalToConstant: 34),
            goBackButton.heightAnchor.constraint(equalToConstant: 34),
            
            goForwardButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            goForwardButton.widthAnchor.constraint(equalToConstant: 34),
            goForwardButton.heightAnchor.constraint(equalToConstant: 34),
            goForwardButton.leadingAnchor.constraint(equalTo: stopButton.trailingAnchor, constant: 18),

            deleteButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24), 
        ])
    }
}


//MARK: - Animation

private extension PlayToolbarView {
    
    func animateLabels() {
        guard let viewModel else {
            os_log("\(RErrors.playViewModelIsNotSetted)")
            return
        }
        UIView.animate(withDuration: 0.1) {
            self.startTimeLabel.text = viewModel.elapsedTimeFormatted
            self.endTimeLabel.text = viewModel.remainingTimeFormatted
            self.layoutIfNeeded()
        }
    }
    
    func setupSubviewsAnimated() {
        guard let viewModel else {
            os_log("\(RErrors.playViewModelIsNotSetted)")
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.progressSlider.value = 0
            self.progressSlider.maximumValue = viewModel.duration
            self.animateLabels()
        }
    }
    
    func animateProgress() {
        guard
            progressSlider.value < progressSlider.maximumValue
        else {
            reset()
            return
        }
        UIView.animate(withDuration: 0.1) {
            self.progressSlider.value += 0.1
            self.animateLabels()
        }
    }
    
    private func animateTappedButton(withSender sender: PlayTolbarButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.2
        } completion: { _ in
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
        }
    }
}


//MARK: - Reusable

extension PlayToolbarView: ReusableView {
    
    func reset() {
        Task {
            UIView.animate(withDuration: 0.2, delay: 0.1) {
                self.progressSlider.value = 0
                self.animateLabels()
            }
        }
    }
}
