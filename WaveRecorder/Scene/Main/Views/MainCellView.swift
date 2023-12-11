//
//  MainCellView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit

//MARK: - Protocol

protocol MainCellViewDelegate: AnyObject {
    func renameDidTapped(_ isEditing: Bool)
}


//MARK: - Impl

final class MainCellView: UIView {
    
    var delegate: MainCellViewDelegate?
    
    //MARK: Variables
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let renameButton = UIButton()
    
    private var record: Record?
    
    private var isEditing = false
    
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTitleLabel()
        setupDateLabel()
        setupDurationLabel()
        setupRenameButton()
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
    
    private func isEditingToggled(_ isEditing: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.renameButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.renameButton.alpha = 0.2
        } completion: { _ in
            self.renameButton.setImage(
                UIImage(systemName: isEditing ? "xmark.circle.fill" : "pencil.circle"), for: .normal
            )
            self.renameButton.transform = .identity
            self.renameButton.alpha = 1
        }
    }
    
    
    //MARK: Action
    
    @objc
    private func renameButtonDidTapped() {
        isEditing.toggle()
        isEditingToggled(isEditing)
        delegate?.renameDidTapped(isEditing)
    }
}
            
//MARK: - Setup

private extension MainCellView {
    
    func setupContentView() {
        addNewSubview(titleLabel)
        addNewSubview(dateLabel)
        addNewSubview(durationLabel)
        addNewSubview(renameButton)
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
    
    func setupRenameButton() {
        renameButton.tintColor = .black
        renameButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        renameButton.addTarget(self, action: #selector(renameButtonDidTapped), for: .touchUpInside)
    }
    
    
    //MARK: Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            renameButton.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            renameButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -24),
            renameButton.heightAnchor.constraint(equalToConstant: 24),
            renameButton.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: renameButton.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }
}
