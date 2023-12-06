//
//  MainCellView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit


//MARK: - Impl

final class MainCellView: UIView {
    
    private var record: Record?
    
    //MARK: Variables
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        setupTitleLabel()
        setupDateLabel()
        setupDurationLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    
    //MARK: Methods
    
    func configureView(withRecord record: Record?) {
        self.record = record
    }
    
    func clearView() {
        titleLabel.text = ""
        dateLabel.text = ""
        durationLabel.text = ""
    }
}
            
//MARK: - Setup

private extension MainCellView {
    
    func setupContentView() {
        addNewSubview(titleLabel)
        addNewSubview(dateLabel)
        addNewSubview(durationLabel)
    }
    
    func setupTitleLabel() {
        titleLabel.text = record?.name ?? "NO DATA"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .left
    }
    
    func setupDateLabel() {
        dateLabel.text = Formatter.instance.formatDate(record?.date ?? .now)
        dateLabel.font = .systemFont(ofSize: 16, weight: .light)
        dateLabel.textAlignment = .left
    }
    
    func setupDurationLabel() {
        durationLabel.text = Formatter.instance.formatDuration(record?.duration ?? 0)
        durationLabel.font = .systemFont(ofSize: 16, weight: .light)
        durationLabel.textAlignment = .right
        durationLabel.isHidden = true
    }
    
    
    //MARK: Constraints
    
    func setupConstraints() {
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
