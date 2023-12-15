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
    func get(subModule: Assembly.SubModule) -> UIView
    func getMainCellViewModel(withRecord record: Record) -> MainCellViewModelProtocol
    func getEditViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> EditViewModelProtocol
    func getPlayViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> PlayViewModelProtocol
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    //MARK: Selection
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record
    }
    
    
    //MARK: Properties
    
    static let builder = Assembly()
    private let services = Services()
    
    
    //MARK: ViewModels

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(storageService: services.storageService)
    }()
}


//MARK: - Public

extension Assembly {
    
    func get(module: Module) -> UIViewController {
        build(module: module)
    }
    
    func get(subModule: SubModule) -> UIView {
        build(subModule: subModule)
    }
    
    func getMainCellViewModel(withRecord record: Record) -> MainCellViewModelProtocol {
        buildMainCellViewModel(withRecord: record)
    }
    
    func getPlayViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> PlayViewModelProtocol {
        buildPlayViewModel(withParentViewModel: parentViewModel, record: record)
    }
    
    func getEditViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> EditViewModelProtocol {
        buildEditViewModel(withParentViewModel: parentViewModel, record: record)
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
            record: record,
            parentViewModel: mainViewModel
        )
    }
    
    func buildEditViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> EditViewModelProtocol {
        EditViewModel(parentViewModel: parentViewModel, record: record)
    }
    
    func buildPlayViewModel(withParentViewModel parentViewModel: MainCellViewModelProtocol, record: Record) -> PlayViewModelProtocol {
        PlayViewModel(
            parentViewModel: parentViewModel,
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

