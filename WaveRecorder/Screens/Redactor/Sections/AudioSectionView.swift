//
//  AudioSectionView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 13.02.2024.
//

import UIKit
import UIComponents
import WRResources

final class AudioSectionView: UIView {

    // MARK: - UI
    private let contentView = UIView()
    private let containerStackView = UIStackView()
    private let audioSectionTitleLabel = TitleLabelView(
        text: WRTitles.audioRecordTitleLabel,
        tColor: WRColors.secondaryText,
        font: .systemFont(ofSize: 18, weight: .bold),
        alignment: .left
    )
    private lazy var recordTitleLabel = TitleLabelView(
        text: "",
        tColor: WRColors.primaryText,
        font: .systemFont(ofSize: 16, weight: .medium),
        alignment: .left
    )
    private lazy var recordDateLabel = TitleLabelView(
        text: "",
        tColor: WRColors.secondaryText,
        font: .systemFont(ofSize: 14, weight: .medium),
        alignment: .left
    )
    private lazy var recordDurationLabel = TitleLabelView(
        text: "",
        tColor: WRColors.liteText,
        font: .systemFont(ofSize: 14, weight: .light),
        alignment: .left
    )
    
    //MARK: Configuration
    func configureWith(title: String, date: String, duration: String) {
        recordTitleLabel.text = title
        recordDateLabel.text = date
        recordDurationLabel.text = duration
    }

    func configureAppereanceWith(backgroundColor: UIColor, shadowColor: UIColor) {
        containerStackView.backgroundColor = backgroundColor
        containerStackView.layer.shadowColor = shadowColor.cgColor
        setupContentView()
        setupRecordSectionStackView()
        setupConstraints()
    }

    // MARK: - On tap
    @objc private func containerStackViewDidTapped() {
        animateContainerStackViewOnTap()
    }
}

// MARK: - Setup (Private)
private extension AudioSectionView {

    func setupContentView() {
        addNewSubview(contentView)
        contentView.addNewSubview(audioSectionTitleLabel)
        contentView.addNewSubview(containerStackView)

        backgroundColor = WRColors.clear
        contentView.backgroundColor = WRColors.clear
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

        setTapGesture(
            toView: containerStackView,
            target: self,
            action: #selector(containerStackViewDidTapped)
        )
    }

    // MARK: - Constraints
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

//MARK: Animation (Private)
private extension AudioSectionView {

    func animateContainerStackViewOnTap() {
        let oldBackgroundColor = containerStackView.backgroundColor
        containerStackView.backgroundColor = WRColors.positiveAction

        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0
        ) {
            self.containerStackView.backgroundColor = oldBackgroundColor
        }
    }
}
