//
//  AudioSectionView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 13.02.2024.
//

import UIKit
import UIComponents
import WRResources


//MARK: - Impl

final class AudioSectionView: UIView {
    
    private let contentView = UIView()
    private let containerStackView = UIStackView()
    
    private let audioSectionTitleLabel = TitleLabelView(
        text: RTitles.audioRecordTitleLabel,
        tColor: .black,
        font: .systemFont(ofSize: 20, weight: .bold),
        alignment: .left
    )
    
    //MARK: - Variables
    
    private lazy var recordTitleLabel = TitleLabelView(
        text: "",
        tColor: .black,
        font: .systemFont(ofSize: 18, weight: .medium),
        alignment: .left
    )
    
    private lazy var recordDateLabel = TitleLabelView(
        text: "",
        tColor: .darkGray,
        font: .systemFont(ofSize: 14, weight: .medium),
        alignment: .left
    )
    
    private lazy var recordDurationLabel = TitleLabelView(
        text: "",
        tColor: .gray,
        font: .systemFont(ofSize: 14, weight: .light),
        alignment: .left
    )
    
    
    //MARK: Configure
    
    func configureWith(title: String, date: String, duration: String) {
        self.recordTitleLabel.text = title
        self.recordDateLabel.text = date
        self.recordDurationLabel.text = duration
    }
    
    func configureAppereanceWith(backgroundColor: UIColor, shadowColor: UIColor) {
        self.containerStackView.backgroundColor = backgroundColor
        self.containerStackView.layer.shadowColor = shadowColor.cgColor
        self.setupContentView()
        self.setupRecordSectionStackView()
        self.setupConstraints()
    }
    
    
    @objc
    private func containerStackViewDidTapped() {
        animateContainerStackViewOnTap()
    }
}


//MARK: - Setup

private extension AudioSectionView {
    
    func setupContentView() {
        addNewSubview(contentView)
        contentView.addNewSubview(audioSectionTitleLabel)
        contentView.addNewSubview(containerStackView)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setupRecordSectionStackView() {
        containerStackView.axis = .vertical
        containerStackView.spacing = 6
        containerStackView.distribution = .fillEqually
        containerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        containerStackView.isLayoutMarginsRelativeArrangement = true
        
        containerStackView.layer.cornerRadius = 12
        containerStackView.layer.shadowOpacity = 0.2
        containerStackView.layer.shadowOffset = .init(width: 1, height: 1)
        
        let subviews = [recordTitleLabel, recordDateLabel, recordDurationLabel]
        subviews.forEach { self.containerStackView.addArrangedSubview($0) }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(containerStackViewDidTapped)
        )
        containerStackView.addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            audioSectionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            audioSectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            audioSectionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: audioSectionTitleLabel.bottomAnchor, constant: 8),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}


//MARK: Animation

private extension AudioSectionView {
     
    func animateContainerStackViewOnTap() {
        let oldBackgroundColor = containerStackView.backgroundColor
        containerStackView.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        
        UIView.animate(
            withDuration: 1,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0
        ) {
            self.containerStackView.backgroundColor = oldBackgroundColor
        }
    }
}

