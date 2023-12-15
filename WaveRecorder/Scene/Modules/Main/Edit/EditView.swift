//
//  EditViewView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit


//MARK: - Impl

final class EditView: UIView {
        
    //MARK: Variables
    
    private let titleLabelField = UITextField()
    private let dateLabel = UILabel()
    private let renameButton = UIButton()
    
    private var viewModel: EditViewModelProtocol?
    
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
        setupTitleLabelField()
        setupDateLabel()
        setupRenameButton()
        setupConstraints()
    }
    
    
    //MARK: Methods
    
    func configureView(withViewModel viewModel: EditViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func clearView() {
        titleLabelField.text = ""
        dateLabel.text = ""
        setNeedsLayout()
    }
    
    private func isEditingToggled(_ isEditing: Bool) {
        animateRenameButton(isEditingStarts: isEditing)
        
        if isEditing {
            titleLabelField.becomeFirstResponder()
        } else {
            titleLabelField.resignFirstResponder()
        }
        
        updateView()
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
    
    
    //MARK: Action
    
    @objc
    private func renameButtonDidTapped() {
        isEditing.toggle()
        isEditingToggled(isEditing)
    }
}
            
//MARK: - Setup

private extension EditView {
    
    func setupContentView() {
        addNewSubview(titleLabelField)
        addNewSubview(dateLabel)
        addNewSubview(renameButton)
    }
    
    func setupTitleLabelField() {
        titleLabelField.text = viewModel?.recordName ?? "NO DATA"
        titleLabelField.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabelField.textAlignment = .left
        titleLabelField.delegate = self
    }
    
    func setupDateLabel() {
        dateLabel.text = Formatter.instance.formatDate(viewModel?.recordedAt ?? .now)
        dateLabel.font = .systemFont(ofSize: 16, weight: .light)
        dateLabel.textAlignment = .left
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


//MARK: - Update

extension EditView {
    
    func updateView() {
        viewModel?.didUpdated = { [weak self] in
            self?.setNeedsLayout()
        }
    }
}


//MARK: - TextField Delegate

extension EditView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isEditing
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newName = textField.text else { return }
        viewModel?.renameRecord(withNewName: newName)
    }
}
