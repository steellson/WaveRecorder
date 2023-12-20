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
    func get(module: Assembly.Module) -> UIViewController
    func get(subModule: Assembly.SubModule) -> PresentationUpdatable
    func getMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    //MARK: Selection
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record(parentVM: MainViewModel)
        case play(parentVM: MainCellViewModelProtocol, record: Record)
        case edit(parentVM: MainCellViewModelProtocol, record: Record)
    }
    
    
    private let services = Services()
    
    
    //MARK: Main View Model

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(storageService: services.storageService)
    }()
}


//MARK: - Public

extension Assembly {
    
    func get(module: Module) -> UIViewController {
        build(module: module)
    }
    
    func get(subModule: SubModule) -> PresentationUpdatable {
        build(subModule: subModule)
    }
    
    func getMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol {
        buildMainCellViewModel(withRecord: record, indexPath: indexPath)
    }
}


//MARK: - Private

private extension Assembly {
    
    func build(module: Module) -> UIViewController {
        switch module {
        case .main:
            MainViewController(viewModel: mainViewModel)
        }
    }
    
    func build(subModule: SubModule) -> PresentationUpdatable {
        switch subModule {
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(
                parentViewModel: mainViewModel,
                recordService: services.recordService
            )
            return RecordView(viewModel: viewModel)
            
        case .edit(let parentVM, let record):
            let viewModel: EditViewModelProtocol = EditViewModel(
                parentViewModel: parentVM,
                record: record
            )
            return EditView(viewModel: viewModel)
            
        case .play(let parentVM, let record):
            let viewModel: PlayViewModelProtocol = PlayViewModel(
                parentViewModel: parentVM,
                audioService: services.audioService,
                record: record
            )
            return PlayToolbarView(viewModel: viewModel)
        }
    }
    
    func buildMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol {
        MainCellViewModel(
            record: record,
            indexPath: indexPath,
            parentViewModel: mainViewModel
        )
    }
}


//MARK: - Services

struct Services {
    let audioService: AudioServiceProtocol = AudioService()
    let recordService: RecordServiceProtocol = RecordService()
    let storageService: StorageServiceProtocol = StorageService()
}


//MARK: - Presentation Updatable

protocol PresentationUpdatable: UIView {
    func updateView()
    func reset()
}
