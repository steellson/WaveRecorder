//
//  Assembly.swift
//  WaveRecorder
//
//  Created by Andrew Steellson.
//

import Foundation
import UIKit


//MARK: - Protocols

protocol IsolatedViewModule: UIView { }
protocol IsolatedControllerModule: UIViewController { }

protocol AssemblyProtocol: AnyObject {
    func get(module: Assembly.Module) -> IsolatedControllerModule
    func get(subModule: Assembly.SubModule) -> IsolatedViewModule
    
    func getMainCellViewModel(withRecord record: AudioRecord, indexPath: IndexPath) -> RecordCellViewModel
    func getEditViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> EditViewModelProtocol
    func getPlayViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> PlayToolbarViewModel
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
    private let audioRepository: AudioRepository = AudioRepositoryImpl()

    private lazy var mainViewModel: MainViewModelProtocol = {
        MainViewModel(
            assemblyBuilder: self,
            audioRepository: audioRepository,
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
    
    func getMainCellViewModel(withRecord record: AudioRecord, indexPath: IndexPath) -> RecordCellViewModel {
        buildMainCellViewModel(withRecord: record, indexPath: indexPath)
    }
    
    func getEditViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> EditViewModelProtocol {
        buildEditViewModel(withRecord: record, parentViewModel: parentViewModel)
    }
    
    func getPlayViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> PlayToolbarViewModel {
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
            let audioRecorder: AudioRecorder = AudioRecorderImpl()
            let viewModel: RecordViewModel = RecordBarViewModelImpl(
                parentViewModel: mainViewModel,
                audioRecorder: audioRecorder
            )
            return RecordBarView(viewModel: viewModel)
        }
    }
    
    func buildMainCellViewModel(withRecord record: AudioRecord, indexPath: IndexPath) -> RecordCellViewModel {
        RecordCellViewModelImpl(
            indexPath: indexPath,
            record: record,
            parentViewModel: mainViewModel,
            assemblyBuilder: self
        )
    }
        
    func buildEditViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> EditViewModelProtocol {
        EditViewModel(
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterProtocol,
            parentViewModel: parentViewModel,
            record: record
        )
    }
    
    func buildPlayViewModel(withRecord record: AudioRecord, parentViewModel: RecordCellViewModel) -> PlayToolbarViewModel {
        let audioPlayer: AudioPlayer = AudioPlayerImpl()
        return PlayToolbarViewModelImpl(
            record: record,
            audioPlayer: audioPlayer,
            parentViewModel: parentViewModel,
            timeRefresher: helperFactory.createHelper(ofType: .timeRefresher) as! TimeRefresherProtocol,
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterImpl
        )
    }
}
