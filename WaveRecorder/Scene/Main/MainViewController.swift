//
//  MainViewController.swift.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import UIKit


//MARK: - Impl

final class MainViewController: BaseController {
    
    private let viewModel: MainViewModelProtocol

    init(
        viewModel: MainViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        
    }
    
    override func setupLayout() {
        super.setupLayout()
        
    }
}
