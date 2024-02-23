//
//  RedactorViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import AVFoundation
import OSLog
import WRAudio
import WRResources


typealias AudioRecordMetadata = (name: String, duration: String, date: String)


//MARK: - Protocol

protocol RedactorViewModel: InterfaceUpdatable {
    var audioRecordMetadata: AudioRecordMetadata { get }
    var videoRecord: VideoRecord? { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
    
    func didSelected(videoWithURL url: URL) async throws -> AVPlayerLayer
    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate)
    func didVideoPlayerTapped()
}


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    private(set) var videoRecord: VideoRecord?
    
    private(set) var elapsedTimeFormatted = "00:00"
    private(set) var remainingTimeFormatted = "00:00"
            
    private let audioRecord: AudioRecord
    private let videoPlayer: VideoPlayer
    private let helpers: HelpersStorage
    private let coordinator: AppCoordinator
    
    
    //MARK: Init
    
    init(
        audioRecord: AudioRecord,
        videoPlayer: VideoPlayer,
        helpers: HelpersStorage,
        coordinator: AppCoordinator
    ) {
        self.audioRecord = audioRecord
        self.videoPlayer = videoPlayer
        self.helpers = helpers
        self.coordinator = coordinator
        
        loadRecordMetadata()
    }
}

//MARK: - Private

private extension RedactorViewModelImpl {
    
    func loadRecordMetadata() {
        self.audioRecordMetadata = AudioRecordMetadata(
            name: helpers.formatter.formatName(audioRecord.name),
            duration: helpers.formatter.formatDuration(audioRecord.duration ?? 0.0),
            date: helpers.formatter.formatDate(audioRecord.date)
        )
    }
    
    func updateTime(withTimeProgress timeProgress: TimeInterval) {
        guard let videoRecord else { return }
        let remainingTime = videoRecord.duration - timeProgress
        let elapsedTime = Double(timeProgress)
        
        elapsedTimeFormatted = helpers.formatter.formatDuration(elapsedTime)
        remainingTimeFormatted = helpers.formatter.formatDuration(remainingTime)
    }
    
    func play() {
        do {
            try videoPlayer.play() { [weak self] timeProgress in
                guard let self else { return }

                Task {
                    self.updateTime(withTimeProgress: timeProgress)
                    try await self.shouldUpdateInterface?(false)
                }
            }
        } catch {
            os_log("\(WRErrors.videoRecordCouldntBePlayad)")
            coordinator.showDefaultAlert(
                withTitle: WRErrors.defaultAlertTitle,
                message: WRErrors.defaultAlertMessage
            )
        }
    }
    
    func pause() {
        videoPlayer.pause()
    }
}


//MARK: - Public

extension RedactorViewModelImpl {
    
    func didSelected(videoWithURL url: URL) async throws -> AVPlayerLayer {
        videoPlayer.configureWith(url: url)
        
        let record = try await videoPlayer.getVideo()
        self.videoRecord = VideoRecord(
            name: record.name,
            url: record.url,
            duration: record.duration,
            frames: record.frames
        )
        self.elapsedTimeFormatted = helpers.formatter.formatDuration(0.0)
        self.remainingTimeFormatted = helpers.formatter.formatDuration(record.duration)
        
        return try videoPlayer.getVideoPlayerLayer()
    }

    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate) {
        coordinator.showVideoPicker(forDelegate: delegate)
    }
    
    func didVideoPlayerTapped() {
        play() // pause()

    }
}
