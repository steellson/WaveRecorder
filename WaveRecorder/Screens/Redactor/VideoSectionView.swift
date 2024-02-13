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
    
    
    //MARK: Configure
    
    func configureWith() {
        
    }
    
    func configureAppereanceWith(backgroundColor: UIColor, shadowColor: UIColor) {
        self.setupContentView()
        self.setupContainerView(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor
        )
        self.setupConstraints()
        self.layoutIfNeeded()
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
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(contanierViewDidTapped)
        )
        containerView.addGestureRecognizer(tapGesture)
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
            videoIsNotSelectedTitle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}


//MARK: Animation

private extension VideoSectionView {
     
    func animateContainerViewOnTap() {
        let oldBackgroundColor = containerView.backgroundColor
        containerView.backgroundColor = .systemRed.withAlphaComponent(0.3)
        
        UIView.animate(
            withDuration: 1,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0
        ) {
            self.containerView.backgroundColor = oldBackgroundColor
        }
    }
}

