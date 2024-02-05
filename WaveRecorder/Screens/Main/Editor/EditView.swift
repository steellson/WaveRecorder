//
//  EditViewView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit
import OSLog
import WRResources

//MARK: - Impl

final class EditView: UIView {
    
    private let viewModel: EditViewModel
        
    //MARK: Variables
    
    private lazy var titleLabelField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 18, weight: .semibold)
        field.backgroundColor = RColors.secondaryBackgroundColor
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = .asciiCapable
        field.returnKeyType = .continue
        field.textAlignment = .left
        field.isEnabled = false
        field.delegate = self
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .left
        label.backgroundColor = RColors.secondaryBackgroundColor
        return label
    }()
    
    private lazy var renameButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.addTarget(self, action: #selector(renameButtonDidTapped), for: .touchUpInside)
        return button
    }()
        
    
    //MARK: Lifecycle
    
    init(
        viewModel: EditViewModel
    ) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupContentView()
        setupConstraints()
        setupSubviewsAnimated()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        titleLabelField.text = ""
        dateLabel.text = ""
        animateRenameButton(isEditingStarts: viewModel.isEditing)
    }

    
    //MARK: Animation
    
    private func setupSubviewsAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.titleLabelField.text = self.viewModel.recordName
            self.titleLabelField.isEnabled = self.viewModel.isEditing
            self.dateLabel.text = self.viewModel.recordedAt
            self.animateRenameButton(isEditingStarts: self.viewModel.isEditing)
        }
    }
    
    private func animateRenameButton(isEditingStarts isEditing: Bool) {
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
    
    private func animateTitleLabelField(isEditing: Bool) {
        self.titleLabelField.isEnabled = isEditing
        UIView.animate(withDuration: 0.2) {
            if isEditing {
                self.titleLabelField.becomeFirstResponder()
                self.titleLabelField.backgroundColor = RColors.primaryBackgroundColor.withAlphaComponent(0.3)
            } else {
                self.titleLabelField.resignFirstResponder()
                self.titleLabelField.backgroundColor = RColors.secondaryBackgroundColor
            }
        }
    }
    
    
    //MARK: Action
    
    @objc
    private func renameButtonDidTapped() {
        viewModel.switchEditing()
        
        animateTitleLabelField(isEditing: viewModel.isEditing)
        animateRenameButton(isEditingStarts: viewModel.isEditing)
    }
}
            
//MARK: - Setup

private extension EditView {
    
    func setupContentView() {
        addNewSubview(titleLabelField)
        addNewSubview(dateLabel)
        addNewSubview(renameButton)
    }
    
    
    //MARK: Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            renameButton.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            renameButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -24),
            renameButton.heightAnchor.constraint(equalToConstant: 24),
            renameButton.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabelField.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabelField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabelField.trailingAnchor.constraint(equalTo: renameButton.leadingAnchor, constant: -12),
            titleLabelField.heightAnchor.constraint(equalToConstant: 18),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabelField.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            dateLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}


//MARK: - TextField Delegate

extension EditView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newName = textField.text else { return }
        
        Task {
            await viewModel.onEndEditing(withNewName: newName)
            
            animateTitleLabelField(isEditing: viewModel.isEditing)
            animateRenameButton(isEditingStarts: viewModel.isEditing)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let newName = textField.text else { return false }
        
        Task {
            await viewModel.onEndEditing(withNewName: newName)
            
            animateTitleLabelField(isEditing: viewModel.isEditing)
            animateRenameButton(isEditingStarts: viewModel.isEditing)
        }
        
        return true
    }
}
