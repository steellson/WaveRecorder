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


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    private(set) var videoRecord: VideoRecord?
    
    private var isPlayingNow = false
    private var elapsedTime = 0.0
    private var remainingTime = 0.0
            
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
        self.elapsedTime = Double(timeProgress)
        self.remainingTime = videoRecord.duration - timeProgress
    }
    
    func play() {
        do {
            try videoPlayer.play() { [weak self] timeProgress in
                guard let self else { return }

                Task {
                    self.isPlayingNow = true
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
        isPlayingNow = false
    }
}


//MARK: - Input

extension RedactorViewModelImpl: RedactorViewProtocol {
    
    func didSelected(videoWithURL url: URL) async throws -> AVPlayerLayer {
        videoPlayer.configureWith(url: url)
        
        let record = try await videoPlayer.getVideo()
        self.videoRecord = VideoRecord(
            name: record.name,
            url: record.url,
            duration: record.duration,
            frames: record.frames
        )
        self.remainingTime = record.duration
        
        return try videoPlayer.getVideoPlayerLayer()
    }

    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate) {
        coordinator.showVideoPicker(forDelegate: delegate)
    }
    
    func didVideoPlayerTapped() {
        isPlayingNow ? pause() : play()
    }
}


//MARK: - Output

extension RedactorViewModelImpl {
    
    func getElapsedTimeString() -> String {
        helpers.formatter.formatDuration(elapsedTime)
    }
    
    func getRemainingTimeString() -> String {
        helpers.formatter.formatDuration(remainingTime)
    }
}
