//
//  WRNavigationController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit


//MARK: - Impl

public final class WRNavigationController: UINavigationController {
    
    //MARK: Init
    
    public init(backgroundColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        setupAppereance(withBackgroundColor: backgroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppereance(withBackgroundColor: .white)
    }
}

//MARK: - Setup

private extension WRNavigationController {
    
    func setupAppereance(withBackgroundColor color: UIColor) {
        navigationBar.backgroundColor = color
    }
}
