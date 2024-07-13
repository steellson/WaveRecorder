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
    func showDefaultAlert(withTitle title: String, message: String)
}

//MARK: - Impl
final class AppCoordinator: Coordinator {

    public var parentCoordinator: Coordinator?
    public var children: [Coordinator] = []
    public var navigationController: UINavigationController

    private let helpersStorage: HelpersStorage = HelpersStorageImpl()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


//MARK: - Methods (Public)
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
        navigationController.pushViewController(mainViewController, animated: true)
    }

    func showRedactorView(withAudioRecord record: AudioRecord) {
        let videoPlayer: VideoPlayer = VideoPlayerImpl()
        let redactorViewModel: RedactorViewModel = RedactorViewModelImpl(
            audioRecord: record,
            videoPlayer: videoPlayer,
            helpers: helpersStorage,
            coordinator: self
        )
        let redactorViewController: RedactorViewController = RedactorViewController(
            viewModel: redactorViewModel
        )
        navigationController.pushViewController(redactorViewController, animated: true)
    }

    func showVideoPicker(forDelegate delegate: VideoPickerDelegate) {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true

        navigationController.present(picker, animated: true)
    }

    func showDefaultAlert(withTitle title: String, message: String) {
        let defaultAlert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "Ok",
            style: .cancel,
            handler: { _ in
                defaultAlert.dismiss(animated: true)
            }
        )
        defaultAlert.addAction(okAction)

        navigationController.present(defaultAlert, animated: true)
    }
}
