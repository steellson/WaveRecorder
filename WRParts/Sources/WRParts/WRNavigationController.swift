//
//  WRNavigationController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit
import WRResources


//MARK: - Impl

public final class WRNavigationController: UINavigationController {
    
    //MARK: Init
    
    public init() {
        super.init(nibName: nil, bundle: nil)
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
