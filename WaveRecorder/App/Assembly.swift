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
    func get(subModule: Assembly.SubModule) -> IsolatedView
    
    func getMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol
    func getEditViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> EditViewModelProtocol
    func getPlayViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> PlayViewModelProtocol
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    //MARK: Selection
    
    enum Module {
        case main
    }
    
    enum SubModule {
        case record(parentVM: MainViewModel)
    }
    
    
    private let services = Services()
    
    //MARK: Main View Model

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(
            assemblyBuilder: self,
            storageService: services.storageService
        )
    }()
}


//MARK: - Public

extension Assembly {
    
    func get(module: Module) -> UIViewController {
        build(module: module)
    }
    
    func get(subModule: SubModule) -> IsolatedView {
        build(subModule: subModule)
    }
    
    func getMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol {
        buildMainCellViewModel(withRecord: record, indexPath: indexPath)
    }
    
    func getEditViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> EditViewModelProtocol {
        buildEditViewModel(withRecord: record, parentViewModel: parentViewModel)
    }
    
    func getPlayViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> PlayViewModelProtocol {
        buildPlayViewModel(withRecord: record, parentViewModel: parentViewModel)
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
    
    func build(subModule: SubModule) -> IsolatedView {
        switch subModule {
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(
                parentViewModel: mainViewModel,
                recordService: services.recordService
            )
            return RecordView(viewModel: viewModel)
        }
    }
    
    func buildMainCellViewModel(withRecord record: Record, indexPath: IndexPath) -> MainCellViewModelProtocol {
        MainCellViewModel(
            indexPath: indexPath,
            record: record,
            parentViewModel: mainViewModel,
            assemblyBuilder: self
        )
    }
        
    func buildEditViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> EditViewModelProtocol {
        EditViewModel(
            parentViewModel: parentViewModel,
            record: record
        )
    }
    
    func buildPlayViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> PlayViewModelProtocol {
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


//MARK: - Isolated View

protocol IsolatedView: UIView { }
