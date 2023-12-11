//
//  PlayToolbarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import UIKit

//MARK: - Protocol

protocol PlayToolbarViewDelegate: AnyObject {
    func goBack()
    func playPause()
    func goForward()
    func deleteRecord()
    func progressDidChanged(onValue value: Float)
}


//MARK: - Impl

final class PlayToolbarView: UIView {
    
    weak var delegate: PlayToolbarViewDelegate?
            
    //MARK: Variables
    
    private let progressSlider = UISlider()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    private var record: Record?
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        setupButtonTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupProgressSlider()
        setupStartTimeLabel()
        setupEndTimeLabel()
        setupConstraints()
    }
    
    
    //MARK: Methods
    
    func configureView(withRecord record: Record?) {
        self.record = record
    }
    
    func clearView() {
        startTimeLabel.text = "00:00"
        endTimeLabel.text = "00:00"
        progressSlider.value = 0
    }
    
    //MARK: Actions
    
    @objc
    private func buttonDidTapped(_ sender: PlayTolbarButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.2
        } completion: { _ in
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let delegate = self?.delegate else {
                print("ERROR: PlayToolbarViewDelegate is not setted!")
                return
            }
            switch sender.type {
            case .goBack: delegate.goBack()
            case .play: delegate.playPause()
            case .goForward: delegate.goForward()
            case .delete: delegate.deleteRecord()
            }
        }
    }
    
    @objc private func progressSliderDidSlide(_ sender: UISlider) {
        if sender == progressSlider {
            delegate?.progressDidChanged(onValue: progressSlider.value)
        } else {
            print("Sender is not a progress slider!")
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
        progressSlider.maximumValue = Float(record?.duration ?? 0)
        progressSlider.backgroundColor = .systemGray
        progressSlider.tintColor = .darkGray
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        progressSlider.addTarget(self, action: #selector(progressSliderDidSlide), for: .valueChanged)
    }
    
    private func setupStartTimeLabel() {
        startTimeLabel.text = Formatter.instance.formatDuration(0)
        startTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private func setupEndTimeLabel() {
        endTimeLabel.text = Formatter.instance.formatDuration(record?.duration ?? 0)
        endTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private func setupButtonTargets() {
        goBackButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    
    //MARK: Constraints

    func setupConstraints() {
        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalToConstant: 38),
            playButton.heightAnchor.constraint(equalToConstant: 38),
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            goBackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -24),
            goBackButton.widthAnchor.constraint(equalToConstant: 34),
            goBackButton.heightAnchor.constraint(equalToConstant: 34),
            goBackButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            goForwardButton.widthAnchor.constraint(equalToConstant: 34),
            goForwardButton.heightAnchor.constraint(equalToConstant: 34),
            goForwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 24),
            goForwardButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            startTimeLabel.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -18),
            startTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            
            endTimeLabel.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -24),
            endTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            progressSlider.heightAnchor.constraint(equalToConstant: 1),
            progressSlider.centerYAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
    }
}
