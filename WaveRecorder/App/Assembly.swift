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
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record
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
            MainViewController(viewModel: mainViewModel)
        }
    }
    
    func build(subModule: SubModule) -> UIView {
        switch subModule {
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(
                parentViewModel: mainViewModel,
                recordService: services.recordService
            )
            return RecordView(viewModel: viewModel)
        }
    }
    
    func buildMainCellViewModel(withRecord record: Record) -> MainCellViewModelProtocol {
        MainCellViewModel(
            parentViewModel: mainViewModel,
            audioService: services.audioService,
            record: record
        )
    }
}


//MARK: - Services

struct Services {
    let audioService: AudioServiceProtocol = AudioService()
    let recordService: RecordServiceProtocol = RecordService()
    let storageService: StorageServiceProtocol = StorageService()
}

