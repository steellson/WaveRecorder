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
    
    enum Module {
        case main
    }
    
    static let builder = Assembly()
    
    private let services = Services()

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(storageService: services.storageService)
    }()

    //MARK: Build
    
    func build(module: Module) -> UIViewController {
        switch module {
            
        case .main:
            let viewController = MainViewController(viewModel: mainViewModel)
            return viewController
        }
    }
}


//MARK: - Services

struct Services {
//    let audioService: AudioServiceProtocol = AudioService()
//    let recordService: RecordServiceProtocol = RecordService()
    let storageService: StorageServiceProtocol = StorageService()
}

