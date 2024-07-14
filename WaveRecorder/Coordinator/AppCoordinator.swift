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
    func startWithMainView()
    func showRedactorView(withAudioRecord record: AudioRecord)
    func showVideoPicker(forDelegate delegate: VideoPickerDelegate)
    func showDefaultAlert(withTitle title: String, message: String)
}

//MARK: - Impl
final class AppCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let builder: Builder

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.builder = BuilderImpl()
    }
}

//MARK: - Methods (Public)
extension AppCoordinator {

    func startWithMainView() {
        let mainModule = builder.buildMain(with: self)
        navigationController.pushViewController(mainModule, animated: true)
    }

    func showRedactorView(withAudioRecord record: AudioRecord) {
        let redactor = builder.buildRedactor(with: record, coordinator: self)
        navigationController.pushViewController(redactor, animated: true)
    }

    func showVideoPicker(forDelegate delegate: VideoPickerDelegate) {
        let videoPicker = builder.buildVideoPicker(with: delegate)
        navigationController.present(videoPicker, animated: true)
    }

    func showDefaultAlert(withTitle title: String, message: String) {
        let defaultAlert = builder.buildDefaultAlert(with: title, message: message)
        navigationController.present(defaultAlert, animated: true)
    }
}
