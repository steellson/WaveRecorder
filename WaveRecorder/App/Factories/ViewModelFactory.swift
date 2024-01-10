////
////  ViewModelFactory.swift
////  WaveRecorder
////
////  Created by Andrew Steellson on 10.01.2024.
////
//
//import Foundation
//
//
////MARK: - Protoocls
//
//protocol ViewModel {}
//
//protocol ViewModelFactoryProtocol: AnyObject {
//    func createViewModel(ofType type: ViewModelType) -> ViewModel
//}
//
//
////MARK: - Type
//
//enum ViewModelType {
//    case main
//    case record
//    case edit
//    case play
//}
//
//
////MARK: - Impl
//
//final class ViewModelFactory: ViewModelFactoryProtocol {
//    
//    private let serviceFactory: ServiceFactoryProtocol
//    private let helpers: Helpers
//    
//    
//    init(
//        serviceFactory: ServiceFactoryProtocol,
//        helpers: Helpers
//    ) {
//        self.serviceFactory = serviceFactory
//        self.helpers = helpers
//    }
//
//    
//    func createViewModel(ofType type: ViewModelType) -> ViewModel {
//        switch type {
//        case .main:
//            let mainViewModel: MainViewModelProtocol = MainViewModel(
//                assemblyBuilder: <#T##AssemblyProtocol#>,
//                storageService: serviceFactory.createService(ofType: .storageService) as! StorageServiceProtocol,
//                notificationCenter: helpers.notificationCenter
//            )
//            return mainViewModel as! ViewModel
//            
//        case .record:
//            let recordViewModel: RecordViewModelProtocol = RecordViewModel(
//                parentViewModel: <#T##MainViewModelProtocol#>,
//                recordService: <#T##RecordServiceProtocol#>
//            )
//            return recordViewModel
//            
//        case .edit:
//            let editViewModel: EditViewModelProtocol = EditViewModel(
//                parentViewModel: <#T##MainCellViewModelProtocol#>,
//                record: <#T##Record#>
//            )
//            return editViewModel
//            
//        case .play:
//            let playViewModel: PlayViewModelProtocol = PlayViewModel(
//                record: <#T##Record#>,
//                audioService: <#T##AudioServiceProtocol#>,
//                parentViewModel: <#T##MainCellViewModelProtocol#>,
//                timeRefresher: <#T##TimeRefresherProtocol#>,
//                formatter: <#T##Formatter#>
//            )
//            return playViewModel
//        }
//    }
//}
