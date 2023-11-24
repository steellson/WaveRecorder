//  BaseView.swift
//
//  Created by Steellson
//

import UIKit


class BaseView: UIView {
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - BaseView Methods Extension

@objc extension BaseView {
    
    func setupView() { }
    
    func setupLayout() { }
}
