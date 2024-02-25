//
//  EditViewView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import UIKit
import OSLog
import WRResources
import UIComponents


//MARK: - Impl

final class EditView: UIView {
    
    private var viewModel: EditViewModel?
        
    //MARK: Variables
    
    private lazy var titleLabelField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 18, weight: .semibold)
        field.backgroundColor = WRColors.secondaryBackground
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = .asciiCapable
        field.returnKeyType = .continue
        field.textAlignment = .left
        field.isEnabled = false
        field.delegate = self
        return field
    }()
    
    private let dateLabel = TitleLabelView(
        text: "",
        tColor: WRColors.secondaryText,
        font: .systemFont(ofSize: 16, weight: .light),
        alignment: .left
    )
    
    private lazy var renameButton: UIButton = {
        let button = UIButton()
        button.tintColor = WRColors.primaryText
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.addTarget(self, action: #selector(renameButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addToVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = WRColors.liteText
        button.setTitle(WRTitles.addToVideoButtonTitle, for: .normal)
        button.titleLabel?.font =  .systemFont(ofSize: 16, weight: .light)
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.backgroundColor = WRColors.secondaryBackground
        button.addTarget(self, action: #selector(addToVideoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupContentView()
        setupConstraints()
        setupSubviewsAnimated()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(viewModel: EditViewModel) {
        self.viewModel = viewModel
        setupSubviewsAnimated()
    }
    
    
    //MARK: Action
    
    @objc
    private func renameButtonDidTapped() {
        guard let viewModel else {
            os_log("\(WRErrors.editViewModelIsNotSetted)")
            return
        }
        viewModel.editDidTapped()
        
        animateTitleLabelField(isEditing: viewModel.isEditingNow())
        animateRenameButton(isEditingStarts: viewModel.isEditingNow())
    }
    
    @objc
    private func addToVideoButtonTapped() {
        guard let viewModel else {
            os_log("\(WRErrors.editViewModelIsNotSetted)")
            return
        }
        viewModel.addToVideoButtonTapped()
    }
}
            
//MARK: - Setup

private extension EditView {
    
    func setupContentView() {
        addNewSubview(titleLabelField)
        addNewSubview(dateLabel)
        addNewSubview(renameButton)
        addNewSubview(addToVideoButton)
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
            dateLabel.heightAnchor.constraint(equalToConstant: 18),
            
            addToVideoButton.topAnchor.constraint(equalTo: titleLabelField.bottomAnchor, constant: 12),
            addToVideoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            addToVideoButton.widthAnchor.constraint(equalToConstant: 100),
            addToVideoButton.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}

//MARK: Animation

private extension EditView {
    
    func setupSubviewsAnimated() {
        guard let viewModel else {
            os_log("\(WRErrors.editViewModelIsNotSetted)")
            return
        }
        let isEditingNow = viewModel.isEditingNow()
        
        UIView.animate(withDuration: 0.3) {
            self.titleLabelField.text = viewModel.getRecordName()
            self.titleLabelField.isEnabled = isEditingNow
            self.dateLabel.text = viewModel.getCreatinonDateString()
            self.animateRenameButton(isEditingStarts: isEditingNow)
        }
    }
    
    
    func animateRenameButton(isEditingStarts isEditing: Bool) {
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
    
    func animateTitleLabelField(isEditing: Bool) {
        self.titleLabelField.isEnabled = isEditing
        UIView.animate(withDuration: 0.2) {
            if isEditing {
                self.titleLabelField.becomeFirstResponder()
                self.titleLabelField.backgroundColor = WRColors.primaryBackground.withAlphaComponent(0.3)
            } else {
                self.titleLabelField.resignFirstResponder()
                self.titleLabelField.backgroundColor = WRColors.secondaryBackground
            }
        }
    }
}


//MARK: - TextField Delegate

extension EditView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard 
            let newName = textField.text,
            let viewModel
        else {
            return
        }
        
        Task {
            try await viewModel.onEndEditing(withNewName: newName)
            
            animateTitleLabelField(isEditing: viewModel.isEditingNow())
            animateRenameButton(isEditingStarts: viewModel.isEditingNow())
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard 
            let newName = textField.text,
            let viewModel
        else {
            return false
        }
        
        Task {
            try await viewModel.onEndEditing(withNewName: newName)
            
            animateTitleLabelField(isEditing: viewModel.isEditingNow())
            animateRenameButton(isEditingStarts: viewModel.isEditingNow())
        }
        
        return true
    }
}


//MARK: - Reusable

extension EditView: ReusableView {
    
    func reset() {
        titleLabelField.text = ""
        dateLabel.text = ""
        animateRenameButton(isEditingStarts: false)
    }
}
