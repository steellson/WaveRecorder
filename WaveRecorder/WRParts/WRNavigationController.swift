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
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setupAppereance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppereance()
    }
}

//MARK: - Setup

private extension WRNavigationController {
    
    func setupAppereance() {
        navigationBar.backgroundColor = RColors.primaryBackgroundColor
    }
}
