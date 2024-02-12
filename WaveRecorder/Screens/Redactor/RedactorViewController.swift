//
//  RedactorViewController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import OSLog
import UIKit
import WRResources



//MARK: - Impl

final class RedactorViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let recordTitleLabel = UILabel()
    private let recordDateLabel = UILabel()
    private let recordDurationLabel = UILabel()
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
        setupTitleLabel()
        setupRecordTitleLabel()
        setupRecordDateLabel()
        setupRecordDurationTabel()
        setupRecordStackView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstrtaints()
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
        view.addNewSubview(recordStackView)
    }

    
    func setupTitleLabel() {
        titleLabel.text = RTitles.redactorMainTite
        titleLabel.textColor = .darkGray
        titleLabel.backgroundColor = RColors.primaryBackgroundColor
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .left
    }
    
    func setupRecordTitleLabel() {
        recordTitleLabel.text = viewModel.audioRecordMetadata.name
        recordTitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        recordTitleLabel.textColor = .black
    }
    
    func setupRecordDateLabel() {
        recordDateLabel.text = viewModel.audioRecordMetadata.date
        recordDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        recordDateLabel.textColor = .darkGray
    }
    
    func setupRecordDurationTabel() {
        recordDurationLabel.text = viewModel.audioRecordMetadata.duration
        recordDurationLabel.font = .systemFont(ofSize: 14, weight: .light)
        recordDurationLabel.textColor = .gray
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
    }
  
    
    
    //MARK: Constraints
    
    func setupConstrtaints() {
        guard let navBar = self.navigationController?.navigationBar else { return }
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            recordStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            recordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            recordStackView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12)
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
}
