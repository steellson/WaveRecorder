//
//  VideoSectionView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 13.02.2024.
//

import AVFoundation
import UIKit
import UIComponents
import WRResources


//MARK: - Impl

final class VideoSectionView: UIView {
    
    private let contentView = UIView()
    private let containerView = UIView()
    private let videoPlayerView = UIView()
    
    //MARK: Variables
    
    private let videoSectionTitleLabel = TitleLabelView(
        text: WRTitles.videoRecordTitleLabel,
        tColor: WRColors.secondaryText,
        font: .systemFont(ofSize: 18, weight: .bold),
        alignment: .left
    )
    
    private let videoIsNotSelectedTitle = TitleLabelView(
        text: WRTitles.videoIsntSelected,
        tColor: WRColors.secondaryText,
        font: .systemFont(ofSize: 26, weight: .bold),
        alignment: .center
    )
    
    private var videoPlayer = AVPlayer()
    private var videoPlayerHeight: CGFloat = 100.0
    
    private lazy var videoFramesView = VideoFramesView()
    private var videoFramesViewHeight = 40.0
    
    private let startTimeLabel = TitleLabelView(
        text: "00:00",
        tColor: WRColors.primaryText,
        font: .systemFont(ofSize: 14, weight: .light)
    )
    
    private let endTimeLabel = TitleLabelView(
        text: "00:00",
        tColor: WRColors.primaryText,
        font: .systemFont(ofSize: 14, weight: .light)
    )
    
    
    //MARK: Configure
    
    func configureWith(videoRecord: VideoRecord?) {
        guard
            let videoRecord,
            let elapsedTime = videoRecord.elapsedTime,
            let remainingTime = videoRecord.remainingTime
        else {
            videoIsNotSelectedTitle.isHidden = false
            videoPlayerView.isHidden = true
            startTimeLabel.isHidden = true
            endTimeLabel.isHidden = true
            
            animateContainerViewOnTap()
            return
        }
        Task {
            videoIsNotSelectedTitle.isHidden = true
            videoPlayerView.isHidden = false
            startTimeLabel.isHidden = false
            endTimeLabel.isHidden = false
            
            setupVideoPlayer(withURL: videoRecord.url)
            videoFramesView.configure(withFrames: videoRecord.frames)
            animateProgressWith(
                elapsedTime: elapsedTime,
                remainingTime: remainingTime
            )
        }
    }
    
    func configureAppereanceWith(backgroundColor: UIColor, shadowColor: UIColor, videoPlayerHeight: CGFloat) {
        setupContentView()
        setupContainerView(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor
        )
        setupVideoPlayerView(withHeight: videoPlayerHeight)
        setupConstraints()
    }
    
    
    //MARK: Actions
    
    @objc
    private func contanierViewDidTapped() {
        guard !videoIsNotSelectedTitle.isHidden else { return }
        animateContainerViewOnTap()
    }
    
    @objc
    private func videoPlayerViewDidTapped() {
        switch videoPlayer.timeControlStatus {
        case .paused:
            videoPlayer.play()
        case .waitingToPlayAtSpecifiedRate:
            videoPlayer.play()
        case .playing:
            videoPlayer.pause()
        @unknown default: return
        }
    }
}


//MARK: - Setup

private extension VideoSectionView {
    
    func setupContentView() {
        addNewSubview(contentView)
        contentView.addNewSubview(videoSectionTitleLabel)
        contentView.addNewSubview(containerView)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    func setupContainerView(backgroundColor: UIColor, shadowColor: UIColor) {
        containerView.backgroundColor = backgroundColor
        containerView.layer.shadowColor = shadowColor.cgColor
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = .init(width: 1, height: 1)
        
        containerView.addNewSubview(videoIsNotSelectedTitle)
        containerView.addNewSubview(videoPlayerView)
        
        setTapGesture(
            toView: containerView,
            target: self,
            action: #selector(contanierViewDidTapped)
        )
    }
    
    func setupVideoPlayerView(withHeight height: CGFloat) {
        videoPlayerHeight = height
        videoPlayerView.backgroundColor = WRColors.clear
        videoPlayerView.layer.cornerRadius = 6
        videoPlayerView.contentMode = .scaleAspectFit
        
        videoPlayerView.addNewSubview(videoFramesView)
        videoPlayerView.addNewSubview(startTimeLabel)
        videoPlayerView.addNewSubview(endTimeLabel)
        
        setTapGesture(
            toView: videoPlayerView,
            target: self,
            action: #selector(videoPlayerViewDidTapped)
        )
    }
    
    func setupVideoPlayer(withURL url: URL) {
        self.videoPlayer = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = videoPlayerView.bounds
        
        videoPlayerView.layer.addSublayer(playerLayer)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            videoSectionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoSectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoSectionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: videoSectionTitleLabel.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            videoIsNotSelectedTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            videoIsNotSelectedTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            videoIsNotSelectedTitle.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            videoIsNotSelectedTitle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            videoPlayerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            videoPlayerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            videoPlayerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            videoPlayerView.heightAnchor.constraint(equalToConstant: videoPlayerHeight),
            
            videoFramesView.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
            videoFramesView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            videoFramesView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            videoFramesView.heightAnchor.constraint(equalToConstant: videoFramesViewHeight),
            
            startTimeLabel.topAnchor.constraint(equalTo: videoFramesView.bottomAnchor, constant: 4),
            startTimeLabel.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor, constant: 8),
            
            endTimeLabel.topAnchor.constraint(equalTo: videoFramesView.bottomAnchor, constant: 4),
            endTimeLabel.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor, constant: -8),
        ])
    }
}


//MARK: Animation

private extension VideoSectionView {
     
    func animateContainerViewOnTap() {
        let oldBackgroundColor = containerView.backgroundColor
        containerView.backgroundColor = WRColors.negativeAction
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            self.containerView.backgroundColor = oldBackgroundColor
        }
    }
    
    private func animateProgressWith(elapsedTime: String, remainingTime: String) {
        UIView.animate(withDuration: 0.1) {
            self.startTimeLabel.text = elapsedTime
            self.endTimeLabel.text = remainingTime
        }
    }
}

