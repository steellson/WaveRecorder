//
//  BaseCell.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 25.10.2023.
//

import UIKit

class BaseCell: UITableViewCell {
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        setupCell()
        setupCellLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - BaseView Methods Extension

@objc extension BaseCell {
    
    func setupCell() { 
        backgroundColor = .clear
    }
    
    func setupCellLayout() { }
        
    func clearCell() { }
}
