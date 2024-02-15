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
        tColor: .black,
        font: .systemFont(ofSize: 20, weight: .bold),
        alignment: .left
    )
    
    private let videoIsNotSelectedTitle = TitleLabelView(
        text: WRTitles.videoIsntSelected,
        tColor: .darkGray,
        font: .systemFont(ofSize: 28, weight: .bold),
        alignment: .center
    )
    
    private lazy var videoTimelineView = VideoTimelineView()
    private var videoTimelineViewHeight = 40.0
    
    private var videoPlayer = AVPlayer()
    private var videoPlayerHeight: CGFloat = 100.0
    
    
    //MARK: Configure
    
    func configureWith(videoMetadata: VideoRecordMetadata?) {
        guard let videoMetadata else {
            videoIsNotSelectedTitle.isHidden = false
            videoPlayerView.isHidden = true
            animateContainerViewOnTap()
            return
        }
        Task {
            videoIsNotSelectedTitle.isHidden = true
            videoPlayerView.isHidden = false
            setupVideoPlayer(withURL: videoMetadata.url)
            videoTimelineView.configure(withFrames: videoMetadata.frames)
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
        videoPlayerView.backgroundColor = .clear
        videoPlayerView.layer.cornerRadius = 6
        videoPlayerView.contentMode = .scaleAspectFit
        videoPlayerView.addNewSubview(videoTimelineView)
        
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
            
            videoTimelineView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            videoTimelineView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            videoTimelineView.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
            videoTimelineView.heightAnchor.constraint(equalToConstant: videoTimelineViewHeight)
        ])
    }
}


//MARK: Animation

private extension VideoSectionView {
     
    func animateContainerViewOnTap() {
        let oldBackgroundColor = containerView.backgroundColor
        containerView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            self.containerView.backgroundColor = oldBackgroundColor
        }
    }
}

