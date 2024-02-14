//
//  RedactorViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import Foundation
import OSLog
import CoreGraphics
import WRAudio


typealias AudioRecordMetadata = (name: String, duration: String, date: String)
typealias VideoRecordMetadata = (name: String, url: URL, thumbnailImage: CGImage?)


//MARK: - Protocol

protocol RedactorViewModel: InterfaceUpdatable {
    var audioRecordMetadata: AudioRecordMetadata { get }
    var videoRecordMetadata: VideoRecordMetadata? { get }
    
    func update(videoMetadata: VideoRecordMetadata) async throws
    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate)
}


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    private(set) var videoRecordMetadata: VideoRecordMetadata?
    
    private let videoPlayer: VideoPlayer = VideoPlayerImpl() // should be imported
    
    private let audioRecord: AudioRecord
    private let helpers: HelpersStorage
    private let coordinator: AppCoordinator
    
    
    //MARK: Init
    
    init(
        audioRecord: AudioRecord,
        helpers: HelpersStorage,
        coordinator: AppCoordinator
    ) {
        self.audioRecord = audioRecord
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
    
    
    func getThumbnailImage(forUrl url: URL) throws -> CGImage? {
        try videoPlayer.getThumbnailImage(forUrl: url)
    }
}


//MARK: - Public

extension RedactorViewModelImpl {
    
    func update(videoMetadata: VideoRecordMetadata) async throws {
        let videoURL = videoMetadata.url
        let thumbnailImage = try self.getThumbnailImage(forUrl: videoMetadata.url)
        let videoMetadataSnapshot = VideoRecordMetadata(
            name: videoMetadata.name,
            url: videoURL,
            thumbnailImage: thumbnailImage
        )
        
        self.videoRecordMetadata = videoMetadataSnapshot
        try await self.shouldUpdateInterface?(false)
    }

    func didSeletVideoButtonTapped(_ delegate: VideoPickerDelegate) {
        coordinator.showVideoPicker(forDelegate: delegate)
    }
}
