//
//  WRNavigationController.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.01.2024.
//

import UIKit

public final class WRNavigationController: UINavigationController {

    public init(backgroundColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        setupAppereance(withBackgroundColor: backgroundColor)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppereance(withBackgroundColor: .white)
    }
}

//MARK: - Setup (Private)
private extension WRNavigationController {

    func setupAppereance(withBackgroundColor color: UIColor) {
        navigationBar.backgroundColor = color
        navigationBar.tintColor = .black
    }
}
