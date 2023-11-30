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
    
    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(storageService: services.storageService)
    }()
    
    private lazy var recordViewModel: RecordViewModelProtocol = {
        RecordViewModel(recordService: services.recordService, parentViewModel: mainViewModel)
    }()
    
    private lazy var playToolbarViewModel: PlayToolbarViewModelProtocol = {
        PlayToolbarViewModel(audioService: services.audioService, parentViewModel: mainViewModel)
    }()
    
    
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
            mainViewModel.childViewModels = [recordViewModel, playToolbarViewModel]
            let viewController = MainViewController(viewModel: mainViewModel)
            return viewController
        }
    }
    
    func build(subModule: SubModule) -> UIView {
        
        switch subModule {
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(
                recordService: services.recordService, 
                parentViewModel: mainViewModel
            )
            let view = RecordView(viewModel: viewModel)
            return view
            
        case .playToolbar:
            let viewModel: PlayToolbarViewModelProtocol = PlayToolbarViewModel(
                audioService: services.audioService,
                parentViewModel: mainViewModel
            )
            let view = PlayToolbarView(viewModel: viewModel)
            return view
        }
    }
}


//MARK: - Services

struct Services {
    let audioService: AudioServiceProtocol = AudioService()
    let recordService: RecordServiceProtocol = RecordService()
    let storageService: StorageServiceProtocol = StorageService()
}

