//
//  UIView+Extension.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import UIKit

extension UIView {
    
    //MARK: Convenience preparing for constraints
    func addNewSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
}
