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
typealias VideoRecordMetadata = (name: String, url: URL)


//MARK: - Protocol

protocol RedactorViewModel: InterfaceUpdatable {
    var audioRecordMetadata: AudioRecordMetadata { get }
    var videoRecordMetadata: VideoRecordMetadata? { get }
    var thumbnailImage: CGImage? { get }
    
    func update(videoMetadata: VideoRecordMetadata) async throws
}


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    private(set) var videoRecordMetadata: VideoRecordMetadata?
    private(set) var thumbnailImage: CGImage?
    
    private let videoPlayer: VideoPlayer = VideoPlayerImpl() // should be imported
    
    private let audioRecord: AudioRecord
    private let helpers: HelpersStorage
    
    
    //MARK: Init
    
    init(
        audioRecord: AudioRecord,
        helpers: HelpersStorage
    ) {
        self.audioRecord = audioRecord
        self.helpers = helpers
        
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
    
    
    func getThumbnailImage(forUrl url: URL) throws {
        self.thumbnailImage = try videoPlayer.getThumbnailImage(forUrl: url)
    }
}


//MARK: - Public

extension RedactorViewModelImpl {
    
    func update(videoMetadata: VideoRecordMetadata) async throws {
        self.videoRecordMetadata = videoMetadata
        try self.getThumbnailImage(forUrl: videoMetadata.url)
        try await self.shouldUpdateInterface?(false)
    }

}
