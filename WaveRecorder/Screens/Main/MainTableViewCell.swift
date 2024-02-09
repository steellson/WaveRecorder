//
//  MainTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 05.02.2024.
//

import UIKit
import OSLog
import WRResources


//MARK: - Impl

final class MainTableViewCell:  UITableViewCell {
    
    static let cellIdentifier = RIdentifiers.cellIdentifier
    
    //MARK: Variables
    
    private var editView = EditView()
    private var playToolbar = PlayToolbarView()
    
    
    //MARK: Methods
    
     func configureCellWith(
        editViewModel: EditViewModel,
        playToolbarViewModel: PlayToolbarViewModel
    ) {
        self.editView.configureWith(viewModel: editViewModel)
        self.playToolbar.configureWith(viewModel: playToolbarViewModel)
        setupSubviews()
        setupConstraints()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        editView.reset()
        playToolbar.reset()
    }
}


//MARK: - Setup

private extension MainTableViewCell {
    
    func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        contentView.backgroundColor = RColors.secondaryBackgroundColor
        
        setupSubviews()
    }
    
    func setupSubviews() {
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
}
