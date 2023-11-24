//
//  UINavigationController+Extension.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import UIKit

extension UINavigationController {
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let transparentAppearance = UINavigationBarAppearance()
        transparentAppearance.configureWithTransparentBackground()
        transparentAppearance.backgroundColor = .clear
        transparentAppearance.shadowColor = .clear
        navigationBar.standardAppearance = transparentAppearance
        navigationBar.compactAppearance = transparentAppearance
        navigationBar.scrollEdgeAppearance = transparentAppearance
    }
}
