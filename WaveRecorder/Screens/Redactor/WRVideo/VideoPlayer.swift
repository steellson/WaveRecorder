//
//  VideoPlayer.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 19.02.2024.
//

import AVFoundation
import OSLog


typealias VideoFrame = CGImage


//MARK: - Protocols

protocol VideoPlayer: AnyObject {
    func configureWith(url: URL)
    func getVideoPlayerLayer() throws -> AVPlayerLayer
    func getVideo() async throws -> VideoRecord
    
    func play(updateTimeCompletion: @escaping (TimeInterval) -> Void) throws
    func pause()
    func stop()
}


//MARK: - Errors

enum VideoPlayerError: Error {
    case cantGetUrl
    case cantGetVideoPlayerInstance
    case cantGetVideoMetadata
    case cantGetVideoFrames
    case cantGetVideoRecord
    case cantUpdateTime
}


//MARK: - Impl

final class VideoPlayerImpl: VideoPlayer {
    
    private var url: URL?
    private var player: AVPlayer?
    private var timer: Timer?
    
    private let videoMetadataManager: VideoMetadataManager
    private let videoFrameGenerator: VideoFrameGenerator
    
    init() {
        self.videoMetadataManager = VideoMetadataManagerImpl()
        self.videoFrameGenerator = VideoFrameGeneratorImpl()
    }
    
    func configureWith(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
    }
    
    func getVideoPlayerLayer() throws -> AVPlayerLayer {
        guard let player else {
            throw VideoPlayerError.cantGetVideoPlayerInstance
        }
        return AVPlayerLayer(player: player)
    }
}


//MARK: - Private

private extension VideoPlayerImpl {
    
    func getVideoMetadata(withURL url: URL) async throws -> VideoMetadata {
        do {
            return try await videoMetadataManager.loadMetadataForVideo(withURL: url)
        } catch {
            os_log("ERROR <VideoPlayer>: Cant get video metadata")
            throw VideoPlayerError.cantGetVideoMetadata
        }
    }
    
    func getVideoFrames(withURL url: URL) async throws -> [VideoFrame] {
        do {
            return try await videoFrameGenerator.getAllFrames(forVideoWithUrl: url)
        } catch {
            os_log("ERROR <VideoPlayer>: Cant get video frames")
            throw VideoPlayerError.cantGetVideoFrames
        }
    }
    
    func updateTime(action: @escaping (TimeInterval) -> Void) throws {
        guard
            let player,
            player.currentTime().seconds != player.currentItem?.duration.seconds
        else {
            self.timer?.invalidate()
            self.timer = nil
            throw VideoPlayerError.cantUpdateTime
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let currentTime = player.currentTime()
            action(currentTime.seconds)
        }
    }
}


//MARK: - Public

extension VideoPlayerImpl {
    
    func getVideo() async throws -> VideoRecord {
        guard let url else {
            throw VideoPlayerError.cantGetUrl
        }
        do {
            let metadata = try await getVideoMetadata(withURL: url)
            let frames = try await getVideoFrames(withURL: url)
            return VideoRecord(
                name: metadata.primary.name,
                url: metadata.primary.url,
                duration: metadata.secondary.duration,
                frames: frames
            )
        } catch {
            os_log("ERROR <VideoPlayer>: Cant get video metadata")
            throw VideoPlayerError.cantGetVideoRecord
        }
    }
    
    func play(updateTimeCompletion: @escaping (TimeInterval) -> Void) throws {
        guard let player else {
            throw VideoPlayerError.cantGetVideoPlayerInstance
        }
        
        do {
            player.play()
            try updateTime(action: updateTimeCompletion)
        } catch {
            throw VideoPlayerError.cantUpdateTime
        }
    }
    
    func pause() {
        player?.pause()
        timer?.invalidate()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}


