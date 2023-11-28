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
    
    private let viewModel: PlayToolbarViewModel
    
    //MARK: Variables
    
    private let progressBar = UIProgressView()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    
    //MARK: Init
    
    init(
        viewModel: PlayToolbarViewModel
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Setup
    
    private func setupContentView() {
        addNewSubview(progressBar)
        addNewSubview(startTimeLabel)
        addNewSubview(endTimeLabel)
        addNewSubview(goBackButton)
        addNewSubview(playButton)
        addNewSubview(goForwardButton)
        addNewSubview(deleteButton)
    }
    
    private func setupProgressBar() {
        
    }
    
    private func setupStartTimeLabel() {
        startTimeLabel.text = "00:00"
    }
    
    private func setupEndTimeLabel() {
        endTimeLabel.text = "03:04"
    }
    
    private func setupButtonTargets() {
        goBackButton.addTarget(self, action: #selector(goBackButtonTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(goPlayButtonTapped), for: .touchUpInside)
        goForwardButton.addTarget(self, action: #selector(goForwardButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTapped), for: .touchUpInside)
    }
    
    
    
    //MARK: Actions
    
    @objc
    private func goBackButtonTapped() {
        viewModel.goBack()
    }
    
    @objc
    private func goPlayButtonTapped() {
        viewModel.play()
    }
    
    @objc
    private func goForwardButtonTapped() {
        viewModel.goForward()
    }
    
    @objc
    private func deleteButtonDidTapped() {
        viewModel.deleteRecord()
    }
    
}


//MARK: - Base

extension PlayToolbarView {
    
    override func setupView() {
        super.setupView()
        setupContentView()
        setupProgressBar()
        setupStartTimeLabel()
        setupEndTimeLabel()
        setupButtonTargets()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 30),
            
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            goBackButton.widthAnchor.constraint(equalToConstant: 24),
            goBackButton.heightAnchor.constraint(equalToConstant: 24),
            goBackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -12),
            goBackButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            goForwardButton.widthAnchor.constraint(equalToConstant: 24),
            goForwardButton.heightAnchor.constraint(equalToConstant: 24),
            goForwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            goForwardButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
