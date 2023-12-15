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
    
    private let progressSlider = UISlider()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    private var viewModel: PlayViewModelProtocol?
        
    private var timer: Timer!
    
    private var isPlaying = false {
        didSet {
            updateButtonImage()
        }
    }
    
    private lazy var elapsedTimeValue: Double = 0.0
    private lazy var remainingTimeValue = Double(viewModel?.recordDuration ?? 0)
    
    private let formatter = Formatter.instance
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        setTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupProgressSlider()
        setupTimeLabels()
        setupConstraints()
    }
    
    
    //MARK: Methods
    
    func configureView(withViewModel viewModel: PlayViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func updatePlayToolbar() {
        viewModel?.onPlaying = { [weak self] isPlaying in
            if isPlaying {
                self?.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self?.updateProgress()
                }
            }
        }
        
        viewModel?.onFinish = { [weak self] isFinished in
            if isFinished {
                self?.resetProgress()
                self?.timer.invalidate()
            }
        }
    }
    
    func resetProgress() {
        UIView.animate(withDuration: 0.2) {
            self.isPlaying = false
            self.progressSlider.value = 0
            self.updateTimeValues(isReset: true)
            self.updateTimeLabels()
            self.layoutIfNeeded()
        }
    }
            
    
    //MARK: Actions
    
    @objc
    private func progressValueChanged() {
        viewModel?.play(atTime: self.progressSlider.value)
        updateProgress()
    }
    
    @objc
    private func buttonDidTapped(_ sender: PlayTolbarButton) {
        if sender == playButton {
            isPlaying.toggle()
        }
        
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.2
        } completion: { _ in
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
        }
        
        DispatchQueue.main.async { [unowned self] in
            switch sender.type {
            case .goBack: 
                self.viewModel?.goBack()
            case .play:
                !self.isPlaying
                ? self.viewModel?.stop()
                : self.viewModel?.play(atTime: self.progressSlider.value)
            case .goForward:
                self.viewModel?.goForward()
            case .delete:
                self.viewModel?.deleteRecord()
            }
        }
    }
}

//MARK: - Update

private extension PlayToolbarView {
    
    func updateProgress() {
        UIView.animate(withDuration: 0.1) {
            self.progressSlider.value += 0.1
            self.updateTimeValues(isReset: false)
            self.updateTimeLabels()
            self.layoutIfNeeded()
        }
    }
    
    func updateButtonImage() {
        UIView.animate(withDuration: 0.1) {
            self.playButton.setImage(
                UIImage(systemName: self.isPlaying ? "stop.fill" : "play.fill"),
                for: .normal
            )
        }
    }
    
    func updateTimeLabels() {
        startTimeLabel.text = formatter.formatDuration(elapsedTimeValue)
        endTimeLabel.text = formatter.formatDuration(remainingTimeValue)
    }
    
    func updateTimeValues(isReset: Bool) {
        guard let viewModel else { return }
        
        let duration = Double(viewModel.recordDuration)
              
        switch isReset {
        case true:
            elapsedTimeValue = 0
            remainingTimeValue = duration
        case false:
            let step = 0.1
            if elapsedTimeValue < duration {
                elapsedTimeValue = Double(progressSlider.value)
                remainingTimeValue = duration - elapsedTimeValue
                
                elapsedTimeValue += step
                remainingTimeValue -= step
            } else {
                viewModel.stop()
            }
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
    
    private func setupProgressSlider() {
        progressSlider.maximumValue = viewModel?.recordDuration ?? 0
        progressSlider.tintColor = .darkGray
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
    }
    
    private func setupTimeLabels() {
        startTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
        endTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
        
        updateTimeLabels()
    }
    
    private func setTargets() {
        goBackButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
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
