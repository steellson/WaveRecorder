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

    func getEditViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> EditViewModel
    func getPlayToolbarViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> PlayToolbarViewModel
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

    private lazy var mainViewModel: MainViewModel = {
        MainViewModelImpl(
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
    
    func getEditViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> EditViewModel {
        buildEditViewModel(withRecord: record, indexPath: indexPath, parentViewModel: parentViewModel)
    }
    
    func getPlayToolbarViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> PlayToolbarViewModel {
        buildPlayViewModel(withRecord: record, indexPath: indexPath, parentViewModel: parentViewModel)
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
        
    func buildEditViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> EditViewModel {
        EditViewModelImpl(
            record: record,
            indexPath: indexPath,
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterProtocol,
            parentViewModel: parentViewModel
        )
    }
    
    func buildPlayViewModel(withRecord record: AudioRecord, indexPath: IndexPath, parentViewModel: MainViewModel) -> PlayToolbarViewModel {
        let audioPlayer: AudioPlayer = AudioPlayerImpl()
        return PlayToolbarViewModelImpl(
            record: record,
            indexPath: indexPath,
            audioPlayer: audioPlayer,
            parentViewModel: parentViewModel,
            timeRefresher: helperFactory.createHelper(ofType: .timeRefresher) as! TimeRefresherProtocol,
            formatter: helperFactory.createHelper(ofType: .formatter) as! FormatterImpl
        )
    }
}
