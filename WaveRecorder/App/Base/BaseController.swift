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
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLayout()
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
