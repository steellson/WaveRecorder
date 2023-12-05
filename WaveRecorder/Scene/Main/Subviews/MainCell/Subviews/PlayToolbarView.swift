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
}


//MARK: - Impl

final class PlayToolbarView: UIView {
    
    private var record: Record?
    
    weak var delegate: PlayToolbarViewDelegate?
            
    //MARK: Variables
    
    private let progressSlider = UISlider()
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let goBackButton = PlayTolbarButton(type: .goBack)
    private let playButton = PlayTolbarButton(type: .play)
    private let goForwardButton = PlayTolbarButton(type: .goForward)
    private let deleteButton = PlayTolbarButton(type: .delete)
    
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupContentView()
        setupProgressSlider()
        setupStartTimeLabel()
        setupEndTimeLabel()
        setupButtonTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    
    //MARK: Methods
    
    func configureView(withRecord record: Record) {
        self.record = record
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
        progressSlider.backgroundColor = .systemGray
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(record?.duration ?? 0)
        progressSlider.thumbTintColor = .gray
    }
    
    private func setupStartTimeLabel() {
        startTimeLabel.text = Formatter.instance.formatDuration(record?.duration ?? 0)
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
            
        ])
    }
}
