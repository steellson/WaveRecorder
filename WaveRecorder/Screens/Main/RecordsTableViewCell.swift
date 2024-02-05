//
//  RecordsTableViewCell.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit
import WRResources

//MARK: - Impl

final class RecordsTableViewCell:  UITableViewCell {
    
    static let cellIdentifier = RIdentifiers.cellIdentifier
    
    
    //MARK: Variables
    
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
    
    func configureCellWith(
        editViewModel: EditViewModel,
        playToolbarViewModel: PlayToolbarViewModel
    ) {
        self.editView.configure(withViewModel: editViewModel)
        self.playToolbar.configure(withViewModel: playToolbarViewModel)
    }
}


//MARK: - Setup

private extension RecordsTableViewCell {
    
    func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        contentView.backgroundColor = RColors.secondaryBackgroundColor
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
