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
    
    
    //MARK: Variables
    
    private var viewModel: MainCellViewModelProtocol?

    private let mainCellView = MainCellView()
    private let playToolbar = PlayToolbarView()
    
    override var isSelected: Bool {
        didSet {
            updateAppereance()
            if isSelected {
                print("selected")
            } else {
                print("deselected")
            }
        }
    }
    
    
    
    func configureCell(withViewModel viewModel: MainCellViewModelProtocol) {
        self.viewModel = viewModel
    }

    
    //MARK: Setup
    
    private func setupContentView() {
        selectionStyle = .gray
        contentView.clipsToBounds = true
        
        contentView.addNewSubview(mainCellView)
        contentView.addNewSubview(playToolbar)
    }
    
    
    //MARK: - Methods
    
    private func updateAppereance() {
//        playToolbar.isHidden = !isSelected
//        playToolbar.heightConstraint?.constant = isSelected ? 80 : 0
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
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 220),
            
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playToolbar.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            playToolbar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playToolbar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playToolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    override func clearCell() {
        super.clearCell()
        mainCellView.clearView()
    }
}
