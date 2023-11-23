//  BaseController.swift
//
//  Created by Steellson
//


import UIKit

class BaseController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
}

//MARK: - BaseController Methods Extension

@objc extension BaseController {
    
     func setupView() {
         view.backgroundColor = R.Colors.primaryBackgroundColor
     }
    
     func setupNavBar() { }
    
     func setupLayout() { }
    
    func setupBindings() { }
}
