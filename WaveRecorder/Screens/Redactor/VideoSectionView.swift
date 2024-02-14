//
//  VideoSectionView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 13.02.2024.
//

import UIKit
import UIComponents
import WRResources


//MARK: - Impl

final class VideoSectionView: UIView {
    
    private let contentView = UIView()
    private let containerView = UIView()
    private let videoPlayerView = UIImageView()
    
    //MARK: Variables
    
    private let videoSectionTitleLabel = TitleLabelView(
        text: RTitles.videoRecordTitleLabel,
        tColor: .black,
        font: .systemFont(ofSize: 20, weight: .bold),
        alignment: .left
    )
    
    private let videoIsNotSelectedTitle = TitleLabelView(
        text: RTitles.videoIsntSelected,
        tColor: .darkGray,
        font: .systemFont(ofSize: 28, weight: .bold),
        alignment: .center
    )
    
    private var videoPlayerHeight: CGFloat = 100.0

    
    //MARK: Configure
    
    func configureWith(videoThumbnail thumbnailImage: CGImage?) {
        guard let cgImage = thumbnailImage else {
            videoIsNotSelectedTitle.isHidden = false
            videoPlayerView.isHidden = true
            animateContainerViewOnTap()
            return
        }
        Task {
            videoIsNotSelectedTitle.isHidden = true
            videoPlayerView.isHidden = false
            videoPlayerView.image = UIImage(cgImage: cgImage)
        }
    }
    
    func configureAppereanceWith(backgroundColor: UIColor, shadowColor: UIColor, videoPlayerHeight: CGFloat) {
        self.setupContentView()
        self.setupContainerView(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor
        )
        self.setupVideoPlayerView(withHeight: videoPlayerHeight)
        self.setupConstraints()
    }
    
    @objc
    private func contanierViewDidTapped() {
        guard !videoIsNotSelectedTitle.isHidden else { return }
        animateContainerViewOnTap()
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
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(contanierViewDidTapped)
        )
        containerView.addGestureRecognizer(tapGesture)
    }
    
    func setupVideoPlayerView(withHeight height: CGFloat) {
        videoPlayerHeight = height
        videoPlayerView.backgroundColor = .darkGray
        videoPlayerView.layer.cornerRadius = 6
        videoPlayerView.contentMode = .scaleAspectFit
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
            videoPlayerView.heightAnchor.constraint(equalToConstant: videoPlayerHeight)
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

