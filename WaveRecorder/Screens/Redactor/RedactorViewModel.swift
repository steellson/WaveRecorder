//
//  RedactorViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import Foundation
import OSLog
import WRAudio


typealias AudioRecordMetadata = (name: String, duration: String, date: String)


//MARK: - Protocol

protocol RedactorViewModel: InterfaceUpdatable {
    var audioRecordMetadata: AudioRecordMetadata { get }
    var videoRecord: VideoRecord? { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
    
    func didSelected(videoWithURL url: URL) async throws
    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate)
}


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    private(set) var videoRecord: VideoRecord?
    
    private(set) var elapsedTimeFormatted = "00:00"
    private(set) var remainingTimeFormatted = "00:00"
    
    private var progress: TimeInterval = TimeInterval(0)
        
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
}


//MARK: - Public

extension RedactorViewModelImpl {
    
    func didSelected(videoWithURL url: URL) async throws {
        videoPlayer.configureWith(url: url)
        let record = try await videoPlayer.getVideo()
   
        self.elapsedTimeFormatted = helpers.formatter.formatDuration(progress)
        self.remainingTimeFormatted = helpers.formatter.formatDuration(record.duration)
        self.videoRecord = VideoRecord(
            name: record.name,
            url: record.url,
            duration: record.duration,
            elapsedTime: elapsedTimeFormatted,
            remainingTime: remainingTimeFormatted,
            frames: record.frames
        )
        try await self.shouldUpdateInterface?(false)
    }

    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate) {
        coordinator.showVideoPicker(forDelegate: delegate)
    }
}
