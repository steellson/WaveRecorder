//
//  MainCellView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit

//MARK: - Impl

final class MainCellView: BaseView {
    
    //MARK: Variables
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .left
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        return label
    }()
    
    
    //MARK: Methods
    
    func configureView(name: String, date: String, duraiton: String) {
        self.titleLabel.text = name
        self.dateLabel.text = date
        self.durationLabel.text = duraiton
    }
    
    func clearView() {
        titleLabel.text = ""
        dateLabel.text = ""
        durationLabel.text = ""
    }

    
    //MARK: Setup
    
    private func setupContentView() {
        addNewSubview(titleLabel)
        addNewSubview(dateLabel)
        addNewSubview(durationLabel)
    }
}
            
//MARK: - Base

extension MainCellView {
    
    override func setupView() {
        super.setupView()
        setupContentView()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }
}
