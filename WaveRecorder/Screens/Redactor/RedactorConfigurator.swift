//
//  RedactorConfigurator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//

import AVFoundation


//MARK: - View

protocol RedactorViewProtocol: AnyObject {
    func didSelected(videoWithURL url: URL) async throws -> AVPlayerLayer
    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate)
    func didVideoPlayerTapped()
}


//MARK: - ViewModel

typealias AudioRecordMetadata = (name: String, duration: String, date: String)

protocol RedactorViewModel: InterfaceUpdatable, RedactorViewProtocol {
    var audioRecordMetadata: AudioRecordMetadata { get }
    var videoRecord: VideoRecord? { get }
    func getElapsedTimeString() -> String
    func getRemainingTimeString() -> String
}
