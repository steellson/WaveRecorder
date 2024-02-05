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
    
    
    //MARK: Init
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


//MARK: - Public

extension AppCoordinator {
    
    func startWithMainView() {
        let mainViewModel: MainViewModel = MainViewModelImpl(
            audioRepository: AudioRepositoryImpl(),
            notificationCenter: HelpersStorage.notificationCenter,
            coordinator: self
        )
        let mainViewController = MainViewController(viewModel: mainViewModel)
        self.navigationController.pushViewController(mainViewController, animated: true)
    }
}
