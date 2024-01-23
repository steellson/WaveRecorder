//
//  WRTableView.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit


//MARK: - Impl

final class WRTableView: UITableView {
    
    override init(
        frame: CGRect,
        style: UITableView.Style
    ) {
        super.init(
            frame: frame,
            style: style
        )
       
        seutupAppereance()
        setupSettings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        seutupAppereance()
        setupSettings()
    }
}

//MARK: - Setup

private extension WRTableView {
    
    func seutupAppereance() {
       backgroundColor = .white
       rowHeight = UITableView.automaticDimension
       layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       layer.cornerRadius = 26
       estimatedRowHeight = 160
    }
    
    func setupSettings() {
        keyboardDismissMode = .onDrag
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
    }
}
