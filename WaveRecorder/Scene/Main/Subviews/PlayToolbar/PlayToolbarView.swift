//
//  PlayToolbarView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import UIKit


//MARK: - Impl

final class PlayToolbarView: BaseView {
        
    private let viewModel: PlayToolbarViewModelProtocol
    
    //MARK: Variables
    
    private let progressSlider = UISlider()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    
    //MARK: Init
    
    init(
        viewModel: PlayToolbarViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(withRecord record: Record) {
        self.viewModel.record = record
    }
    
    
    //MARK: Setup
    
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
        progressSlider.backgroundColor = .systemGray
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(viewModel.record?.duration ?? 0)
        progressSlider.thumbTintColor = .gray
    }
    
    private func setupStartTimeLabel() {
        startTimeLabel.text = "00:00"
        startTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private func setupEndTimeLabel() {
        endTimeLabel.text = "03:04"
        endTimeLabel.font = .systemFont(ofSize: 14, weight: .light)
    }
    
    private func setupButtonTargets() {
        goBackButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }

    @objc
    private func buttonDidTapped(_ sender: PlayTolbarButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.2
        } completion: { _ in
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
        }
        
        DispatchQueue.main.async { [unowned self] in
            switch sender.type {
            case .goBack: self.viewModel.goBack()
            case .play: self.viewModel.playPause()
            case .goForward: self.viewModel.goForward()
            case .delete: self.viewModel.deleteRecord()
            }
        }
    }
}


//MARK: - Base

extension PlayToolbarView {
    
    override func setupView() {
        super.setupView()
        setupContentView()
        setupProgressSlider()
        setupStartTimeLabel()
        setupEndTimeLabel()
        setupButtonTargets()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
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
            
            startTimeLabel.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -24),
            startTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            endTimeLabel.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -24),
            endTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            progressSlider.heightAnchor.constraint(equalToConstant: 1),
            progressSlider.bottomAnchor.constraint(equalTo: endTimeLabel.topAnchor, constant: -24)
        ])
    }
}
