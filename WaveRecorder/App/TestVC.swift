//
//  TestVC.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 14.12.2023.
//

import UIKit

//MARK: - Impl

final class TestVC: UIViewController {
    
    private let recordVisualizerView = RecordVisualizerView()
    private let button = PlayTolbarButton(type: .play)
        
    private var isPlaying = false
    
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRecordVisualizerView()
        setupButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.recordVisualizerView.setNeedsLayout()
    }
}


//MARK: - Setup

private extension TestVC {
    
    func setupView() {
        view.backgroundColor = .white
        view.addNewSubview(recordVisualizerView)
        view.addSubview(button)
    }
    
    func setupRecordVisualizerView() {
        recordVisualizerView.backgroundColor = .systemGreen
        recordVisualizerView.clipsToBounds = true
        recordVisualizerView.configureWith(
            numbreOfColumns: 20,
            duration: 0.5,
            rate: 0.1,
            color: .systemGreen
        )
        
        NSLayoutConstraint.activate([
            recordVisualizerView.topAnchor.constraint(equalTo: view.centerYAnchor),
            recordVisualizerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            recordVisualizerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            recordVisualizerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
  
    
    func setupButton() {
        button.frame = CGRect(
            x: view.center.x,
            y: view.center.y + 200,
            width: 50,
            height: 50
        )
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.tintColor = .white
        button.addTarget(self, action: #selector(playDidTapped), for: .touchUpInside)
    }
}


//MARK: - Private

private extension TestVC {
    
    @objc
    func playDidTapped() {
        isPlaying.toggle()
        
        if isPlaying {
            recordVisualizerView.animationStart()
        } else {
            recordVisualizerView.animationStop()
        }
    }
}

