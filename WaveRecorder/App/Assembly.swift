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
    func buildMainCellViewModel(withRecord record: Record) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    static let builder = Assembly()
    
    private let services = Services()
    
    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(storageService: services.storageService)
    }()

    
    //MARK: Modules
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record
    }
    
    
    
    //MARK: Build
    
    func build(module: Module) -> UIViewController {
        switch module {
            
        case .main:
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
        }
    }
    
    func buildMainCellViewModel(withRecord record: Record) -> MainCellViewModelProtocol {
        let mainCellViewModel: MainCellViewModelProtocol = MainCellViewModel(
            audioService: services.audioService,
            parentViewModel: mainViewModel,
            record: record
        )
        return mainCellViewModel
    }

}


//MARK: - Services

struct Services {
    let audioService: AudioServiceProtocol = AudioService()
    let recordService: RecordServiceProtocol = RecordService()
    let storageService: StorageServiceProtocol = StorageService()
}

