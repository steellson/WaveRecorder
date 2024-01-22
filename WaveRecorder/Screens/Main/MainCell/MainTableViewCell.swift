//
//  MainTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit


//MARK: - Impl

final class MainTableViewCell:  UITableViewCell {
    
    static let mainTableViewCellIdentifier = R.Strings
        .Identifiers
        .mainTableViewCellIdentifier
        .rawValue
    
    
    //MARK: Variables
    
    private var viewModel: MainCellViewModelProtocol!
    
    private let editView = EditView()
    private let playToolbar = PlayToolbarView()
    
    
    //MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContentView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetChilds()
    }
    
    
    //MARK: Methods
    
    func configureCell(withViewModel viewModel: MainCellViewModelProtocol) {
        self.viewModel = viewModel
        self.editView.configure(withViewModel: viewModel.makeEditViewModel())
        self.playToolbar.configure(withViewModel: viewModel.makePlayViewModel())
    }
}


//MARK: - Setup

private extension MainTableViewCell {
    
    func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        contentView.backgroundColor = R.Colors.secondaryBackgroundColor
        contentView.addNewSubview(editView)
        contentView.addNewSubview(playToolbar)
    }
    
    
    //MARK: Constriants

    func setupConstraints() {
        NSLayoutConstraint.activate([
            editView.topAnchor.constraint(equalTo: contentView.topAnchor),
            editView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editView.heightAnchor.constraint(equalToConstant: 70),
            
            playToolbar.topAnchor.constraint(equalTo: editView.bottomAnchor),
            playToolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playToolbar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func resetChilds() {
        editView.reset()
        playToolbar.reset()
    }
}
