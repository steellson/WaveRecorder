//
//  Coordinator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 05.02.2024.
//

import UIKit
import WRAudio


//MARK: Protocol

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    
    var navigationController: UINavigationController { get set }
    
    func startWithMainView()
}


//MARK: - Impl

final class AppCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let helpersStorage: HelpersStorage = HelpersStorageImpl()
    
    
    //MARK: Init
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


//MARK: - Public

extension AppCoordinator {
    
    func startWithMainView() {
        let audioPlayer: AudioPlayer = AudioPlayerImpl()
        let audioRepository: AudioRepository = AudioRepositoryImpl()
        let mainViewModel: MainViewModel = MainViewModelImpl(
            audioPlayer: audioPlayer,
            audioRepository: audioRepository,
            helpers: helpersStorage,
            coordinator: self
        )
        let mainViewController = MainViewController(viewModel: mainViewModel)
        self.navigationController.pushViewController(mainViewController, animated: true)
    }
}
