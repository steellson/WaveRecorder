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
        font: .systemFont(ofSize: 26, weight: .bold),
        alignment: .center
    )
    
    private let audioRecordTitleLabel = TitleLabelView(
        text: RTitles.audioRecordTitleLabel,
        tColor: .black,
        font: .systemFont(ofSize: 20, weight: .bold)
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
        setupRecordStackView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstrtaints()
    }
    
    
    //MARK: Actions
    
    @objc
    private func recordStackViewDidTapped() {
        animateRecordStackViewOnTap()
    }
}


//MARK: - Setup

private extension RedactorViewController {
    
    func seutpNavigationBar() {
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem()
    }
    
    func setupContentView() {
        view.backgroundColor = RColors.primaryBackgroundColor
        view.addNewSubview(titleLabel)
        view.addNewSubview(audioRecordTitleLabel)
        view.addNewSubview(recordStackView)
    }
    
    func setupRecordStackView() {
        recordStackView.axis = .vertical
        recordStackView.spacing = 6
        recordStackView.distribution = .fillEqually
        recordStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        recordStackView.isLayoutMarginsRelativeArrangement = true
        recordStackView.backgroundColor = RColors.secondaryBackgroundColor.withAlphaComponent(0.8)
        recordStackView.layer.cornerRadius = 12
        recordStackView.layer.shadowColor = UIColor.black.cgColor
        recordStackView.layer.shadowOpacity = 0.2
        recordStackView.layer.shadowOffset = .init(width: 1, height: 1)
        
        let subviews = [recordTitleLabel, recordDateLabel, recordDurationLabel]
        subviews.forEach { self.recordStackView.addArrangedSubview($0) }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(recordStackViewDidTapped)
        )
        recordStackView.addGestureRecognizer(tapGesture)
    }
  
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            audioRecordTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            audioRecordTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            audioRecordTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            recordStackView.topAnchor.constraint(equalTo: audioRecordTitleLabel.bottomAnchor, constant: 8),
            recordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            recordStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
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
