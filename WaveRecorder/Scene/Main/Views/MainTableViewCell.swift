//
//  MainTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit

//MARK: - Impl

final class MainTableViewCell: BaseCell {
    
    static let mainTableViewCellIdentifier = R.Strings.mainTableViewCellIdentifier.rawValue
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .left
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .right
        return label
    }()
    
    
    func configureCell(name: String, date: String, duraiton: String) {
        self.titleLabel.text = name
        self.dateLabel.text = date
        self.durationLabel.text = duraiton
    }
    
    
    //MARK: Setup
    
    private func setupContentView() {
        selectionStyle = .gray
        contentView.addNewSubview(titleLabel)
        contentView.addNewSubview(dateLabel)
        contentView.addNewSubview(durationLabel)
    }
    
    private func clear() {
        titleLabel.text = ""
        dateLabel.text = ""
        durationLabel.text = ""
    }
    
}
            
//MARK: - Base

extension MainTableViewCell {
    
    override func setupCell() {
        super.setupCell()
        setupContentView()
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    override func clearCell() {
        super.clearCell()
        clear()
    }
}
