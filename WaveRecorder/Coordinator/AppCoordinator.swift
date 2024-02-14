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
    func showRedactorView(withAudioRecord record: AudioRecord)
    func showVideoPicker(forDelegate delegate: VideoPickerDelegate)
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
        let audioRepository: AudioRepository = AudioRepositoryImpl()
        let audioPlayer: AudioPlayer = AudioPlayerImpl()
        let mainViewModel: MainViewModel = MainViewModelImpl(
            audioRepository: audioRepository,
            audioPlayer: audioPlayer,
            helpers: helpersStorage,
            coordinator: self
        )
        let mainViewController = MainViewController(viewModel: mainViewModel)
        self.navigationController.pushViewController(mainViewController, animated: true)
    }
    
    func showRedactorView(withAudioRecord record: AudioRecord) {
        let redactorViewModel: RedactorViewModel = RedactorViewModelImpl(
            audioRecord: record,
            helpers: helpersStorage,
            coordinator: self
        )
        let redactorViewController: RedactorViewController = RedactorViewController(
            viewModel: redactorViewModel
        )
        self.navigationController.pushViewController(redactorViewController, animated: true)
    }
    
    func showVideoPicker(forDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        
        self.navigationController.present(picker, animated: true)
    }
}
