//
//  UIView+Extension.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import UIKit

extension UIView {
    
    //MARK: Convenienve find height constaint
    var heightConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set {
            setNeedsLayout()
        }
    }
    
    //MARK: Convenience preparing for constraints
    func addNewSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
}
