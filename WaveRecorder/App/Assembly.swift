//
//  Assembly.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import Foundation
import UIKit


//MARK: - Protocol

protocol AssemblyProtocol: AnyObject {
    func build(module: Assembly.Module) -> UIViewController
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    static let builder = Assembly()
    
    private let services = Services()
    
    
    //MARK: Modules
    
    enum Module {
        case main
    }
    
    
    //MARK: Build
    
    func build(module: Module) -> UIViewController {
        switch module {
            
        case .main:
            let viewModel: MainViewModelProtocol = MainViewModel()
            let viewController = MainViewController(viewModel: viewModel)
            return viewController
        }
    }
}


//MARK: - Services

struct Services {
    
}
