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
    
    
    
    func configureCell() {
        
    }
    
    
    //MARK: Setup
    
    private func setupContentView() {
        selectionStyle = .none
        contentView.layer.cornerRadius = 14
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
        
    }
    
    override func clearCell() {
        super.clearCell()
        
    }
}
