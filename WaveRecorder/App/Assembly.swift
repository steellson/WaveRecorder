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
    func build(subModule: Assembly.SubModule) -> UIView
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    static let builder = Assembly()
    
    private let services = Services()
    
    
    //MARK: Modules
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record
        case playToolbar
    }
    
    
    //MARK: Build
    
    func build(module: Module) -> UIViewController {
        switch module {
            
        case .main:
            let viewModel: MainViewModelProtocol = MainViewModel(storageService: services.storageService)
            let viewController = MainViewController(viewModel: viewModel)
            return viewController
        }
    }
    
    func build(subModule: SubModule) -> UIView {
        switch subModule {
            
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(recordService: services.recordService)
            let view = RecordView(viewModel: viewModel)
            return view
            
        case .playToolbar:
            let viewModel: PlayToolbarViewModelProtocol = PlayToolbarViewModel(storageService: services.storageService)
            let view = PlayToolbarView(viewModel: viewModel)
            return view
        }
    }
}


//MARK: - Services

struct Services {
    let storageService: StorageServiceProtocol = StorageService()
    let recordService: RecordServiceProtocol = RecordService()
}
