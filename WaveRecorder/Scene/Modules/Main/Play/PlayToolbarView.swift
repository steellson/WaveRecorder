//
//  PlayToolbarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import UIKit

//MARK: - Impl

final class PlayToolbarView: UIView {
                
    //MARK: Variables
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = viewModel.duration
        slider.tintColor = .darkGray
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.backgroundColor = R.Colors.secondaryBackgroundColor
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.backgroundColor = R.Colors.secondaryBackgroundColor
        return label
    }()
    
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    private let viewModel: PlayViewModelProtocol

    
    
    
    //MARK: Lifecycle
    
    init(
        viewModel: PlayViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupContentView()
        setupConstraints()
        setTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Methods
     
    private func animateTappedButton(withSender sender: PlayTolbarButton) {
        let isPlaying = viewModel.isPlaying
        
        UIView.animate(withDuration: 0.1) {
            if sender == self.playButton {
                self.playButton.setImage(
                    UIImage(systemName: !isPlaying ? "stop.fill" : "play.fill"),
                    for: .normal
                )
            }
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.2
        } completion: { _ in
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
        }
    }

    
    //MARK: Actions
    
    @objc
    private func progressValueChanged() {
        viewModel.play(atTime: progressSlider.value) { [weak self] timeInterval in
            self?.updateView()
        }
    }
    
    @objc
    private func toolBarButtonDidTapped(_ sender: PlayTolbarButton) {
        animateTappedButton(withSender: sender)
        
        switch sender.type {
        case .goBack:
            viewModel.goBack()
        case .play:
            viewModel.isPlaying
            ? viewModel.stop() { [weak self] in
                self?.reset()
            }
            : viewModel.play(atTime: progressSlider.value) { [weak self] timeInterval in
                self?.updateView()
            }
        case .goForward:
            viewModel.goForward()
        case .delete:
            viewModel.deleteRecord()
        }
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
        addNewSubview(goForwardButton)
        addNewSubview(deleteButton)
    }
    
    private func setTargets() {
        goBackButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(toolBarButtonDidTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(progressValueChanged), for: .valueChanged)
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
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            goBackButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            goBackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -24),
            goBackButton.widthAnchor.constraint(equalToConstant: 34),
            goBackButton.heightAnchor.constraint(equalToConstant: 34),
            
            goForwardButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            goForwardButton.widthAnchor.constraint(equalToConstant: 34),
            goForwardButton.heightAnchor.constraint(equalToConstant: 34),
            goForwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 18),

            deleteButton.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 18),
            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24), 
        ])
    }
}


//MARK: - Presentation Updatable

extension PlayToolbarView: PresentationUpdatable {

    func updateView() {
        let progressValue = self.viewModel.progress / self.viewModel.duration
        
        UIView.animate(withDuration: 0.1) {
            self.progressSlider.value += progressValue
            self.startTimeLabel.text = self.viewModel.elapsedTimeFormatted
            self.endTimeLabel.text = self.viewModel.remainingTimeFormatted
            self.layoutIfNeeded()
        }
    }
    
    func reset() {
        UIView.animate(withDuration: 0.2, delay: 0.5) {
            self.progressSlider.value = 0
            self.startTimeLabel.text = self.viewModel.elapsedTimeFormatted
            self.endTimeLabel.text = self.viewModel.remainingTimeFormatted
            self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.layoutIfNeeded()
        }
    }
}
