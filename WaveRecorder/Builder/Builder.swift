//
//  Builder.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 14.07.2024.
//

import UIKit
import WRAudio

// MARK: - Protocol
protocol Builder {
    func buildMain(with coordinator: Coordinator) -> UIViewController
    func buildRedactor(with record: AudioRecord, coordinator: AppCoordinator) -> UIViewController
    func buildVideoPicker(with delegate: VideoPickerDelegate) -> UIImagePickerController
    func buildDefaultAlert(with title: String, message: String) -> UIAlertController
}

// MARK: - Impl
final class BuilderImpl: Builder {

    private let helpersStorage: HelpersStorage

    init() {
        self.helpersStorage = HelpersStorageImpl()
    }
}

// MARK: - Methods (Public)
extension BuilderImpl {

    func buildMain(with coordinator: Coordinator) -> UIViewController {
        let audioRepository: AudioRepository = AudioRepositoryImpl()
        let audioPlayer: AudioPlayer = AudioPlayerImpl()
        let mainViewModel: MainViewModel = MainViewModelImpl(
            audioRepository: audioRepository,
            audioPlayer: audioPlayer,
            helpers: helpersStorage,
            coordinator: coordinator
        )
        let mainViewController = MainViewController(viewModel: mainViewModel)
        return mainViewController
    }

    func buildRedactor(
        with record: AudioRecord,
        coordinator: AppCoordinator
    ) -> UIViewController {
        let videoPlayer: VideoPlayer = VideoPlayerImpl()
        let redactorViewModel: RedactorViewModel = RedactorViewModelImpl(
            audioRecord: record,
            videoPlayer: videoPlayer,
            helpers: helpersStorage,
            coordinator: coordinator
        )
        let redactorViewController: RedactorViewController = RedactorViewController(
            viewModel: redactorViewModel
        )
        return redactorViewController
    }

    func buildVideoPicker(with delegate: VideoPickerDelegate) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        return picker
    }

    func buildDefaultAlert(with title: String, message: String) -> UIAlertController {
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
        return defaultAlert
    }
}
