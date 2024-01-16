//
//  Assembly.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import Foundation
import UIKit


//MARK: - Protocols

protocol IsolatedViewModule: UIView { }
protocol IsolatedControllerModule: UIViewController { }

protocol AssemblyProtocol: AnyObject {
    func get(module: Assembly.Module) -> IsolatedControllerModule
    func get(subModule: Assembly.SubModule) -> IsolatedViewModule
    
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
    
    
    private let helperFactory: HelperFactory = HelperFactoryImpl()
    private lazy var serviceFactory: ServiceFactory = ServiceFactoryImpl(helperFactory: helperFactory)
    
    
    //MARK: Main View Model

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(
            assemblyBuilder: self,
            storageService: serviceFactory.createService(ofType: .storageService) as! StorageServiceProtocol,
            notificationCenter: helperFactory.createHelper(ofType: .notificationCenter) as! NotificationCenter
        )
    }()
}


//MARK: - Public

extension Assembly {
    
    func get(module: Module) -> IsolatedControllerModule {
        build(module: module)
    }
    
    func get(subModule: SubModule) -> IsolatedViewModule {
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
    
    func build(module: Module) -> IsolatedControllerModule {
        switch module {
        case .main:
            MainViewController(viewModel: mainViewModel)
        }
    }
    
    func build(subModule: SubModule) -> IsolatedViewModule {
        switch subModule {
        case .record:
            let viewModel: RecordViewModelProtocol = RecordViewModel(
                parentViewModel: mainViewModel,
                recordService: serviceFactory.createService(ofType: .recordService) as! RecordServiceProtocol
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
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterProtocol,
            parentViewModel: parentViewModel,
            record: record
        )
    }
    
    func buildPlayViewModel(withRecord record: Record, parentViewModel: MainCellViewModelProtocol) -> PlayViewModelProtocol {
        PlayViewModel(
            record: record,
            audioService: serviceFactory.createService(ofType: .audioService) as! AudioServiceProtocol,
            parentViewModel: parentViewModel,
            timeRefresher: helperFactory.createHelper(ofType: .timeRefresher) as! TimeRefresherProtocol,
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterImpl
        )
    }
}
