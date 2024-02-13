//
//  RedactorViewController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import OSLog
import UIKit
import UIComponents
import WRResources



//MARK: - Impl

final class RedactorViewController: UIViewController {
        
    private let titleLabel = TitleLabelView(
        text: RTitles.redactorMainTite,
        tColor: .darkGray,
        font: .systemFont(ofSize: 30, weight: .bold),
        alignment: .center
    )
    
    private let audioSectionTitleLabel = TitleLabelView(
        text: RTitles.audioRecordTitleLabel,
        tColor: .black,
        font: .systemFont(ofSize: 20, weight: .bold),
        alignment: .left
    )
    
    private lazy var recordTitleLabel = TitleLabelView(
        text: viewModel.audioRecordMetadata.name,
        tColor: .black,
        font: .systemFont(ofSize: 18, weight: .medium),
        alignment: .left
    )
    
    private lazy var recordDateLabel = TitleLabelView(
        text: viewModel.audioRecordMetadata.date,
        tColor: .darkGray,
        font: .systemFont(ofSize: 14, weight: .medium),
        alignment: .left
    )
    
    private lazy var recordDurationLabel = TitleLabelView(
        text: viewModel.audioRecordMetadata.duration,
        tColor: .gray,
        font: .systemFont(ofSize: 14, weight: .light),
        alignment: .left
    )
    
    private let recordStackView = UIStackView()

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
    
    private let videoSectionView = UIView()
 
    
    private let viewModel: RedactorViewModel

    
    //MARK: Lifecycle
    
    init(
        viewModel: RedactorViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seutpNavigationBar()
        setupContentView()
        setupRecordSectionStackView()
        setupVideoSectionView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstrtaints()
    }
    
    
    //MARK: Actions
    
    @objc
    private func selectVideoButtonTapped() {
        
    }
    
    @objc
    private func recordStackViewDidTapped() {
        animateRecordStackViewOnTap()
    }
}


//MARK: - Setup

private extension RedactorViewController {
    
    func seutpNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: RTitles.selectVideo,
            style: .plain,
            target: self,
            action: #selector(selectVideoButtonTapped)
        )
    }
    
    func setupContentView() {
        view.backgroundColor = RColors.primaryBackgroundColor
        view.addNewSubview(titleLabel)
        view.addNewSubview(audioSectionTitleLabel)
        view.addNewSubview(recordStackView)
        view.addNewSubview(videoSectionTitleLabel)
        view.addNewSubview(videoSectionView)
    }
    
    func setupSection(_ view: UIView) {
        view.backgroundColor = RColors.secondaryBackgroundColor.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .init(width: 1, height: 1)
    }
    
    func setupRecordSectionStackView() {
        recordStackView.axis = .vertical
        recordStackView.spacing = 6
        recordStackView.distribution = .fillEqually
        recordStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        recordStackView.isLayoutMarginsRelativeArrangement = true
        setupSection(recordStackView)
        
        let subviews = [recordTitleLabel, recordDateLabel, recordDurationLabel]
        subviews.forEach { self.recordStackView.addArrangedSubview($0) }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(recordStackViewDidTapped)
        )
        recordStackView.addGestureRecognizer(tapGesture)
    }
    
    func setupVideoSectionView() {
        videoSectionView.addNewSubview(videoIsNotSelectedTitle)
        setupSection(videoSectionView)
    }
    

  
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            audioSectionTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            audioSectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            audioSectionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            recordStackView.topAnchor.constraint(equalTo: audioSectionTitleLabel.bottomAnchor, constant: 8),
            recordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            recordStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            videoSectionTitleLabel.topAnchor.constraint(equalTo: recordStackView.bottomAnchor, constant: 22),
            videoSectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            videoSectionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            videoSectionView.topAnchor.constraint(equalTo: videoSectionTitleLabel.bottomAnchor, constant: 8),
            videoSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            videoSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            videoSectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            
            videoIsNotSelectedTitle.leadingAnchor.constraint(equalTo: videoSectionView.leadingAnchor, constant: 16),
            videoIsNotSelectedTitle.trailingAnchor.constraint(equalTo: videoSectionView.trailingAnchor, constant: -16),
            videoIsNotSelectedTitle.centerXAnchor.constraint(equalTo: videoSectionView.centerXAnchor),
            videoIsNotSelectedTitle.centerYAnchor.constraint(equalTo: videoSectionView.centerYAnchor)
        ])
    }
}

//MARK: Animation

private extension RedactorViewController {
    
    func animateUpdatedLayout() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1
        ) {
            Task {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func animateRecordStackViewOnTap() {
        recordStackView.alpha = 0.5
        UIView.animate(withDuration: 0.2) {
            self.recordStackView.alpha = 1
        }
    }
}
