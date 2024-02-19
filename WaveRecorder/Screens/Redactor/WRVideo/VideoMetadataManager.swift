//
//  VideoMetadataManager.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 19.02.2024.
//

import AVFoundation
import OSLog


//MARK: - Protocol

public protocol VideoMetadataManager: AnyObject {
    func loadMetadataForVideo(withURL url: URL) async throws -> VideoMetadata
}

//MARK: - Error

public enum VideoMetadataManagerError: Error {
    case cantDecodeMetadata
    case cantReturnMetadata
}


//MARK: - Impl

final public class VideoMetadataManagerImpl: VideoMetadataManager {
    
    public init() {}
}


//MARK: - Private

private extension VideoMetadataManagerImpl {
    
    func loadPrimaryMetadata(_ url: URL) -> PrimaryVideoData {
        PrimaryVideoData(
            name: url.lastPathComponent,
            url: url
        )
    }
    
    func loadSecondaryMetadata(_ url: URL) async throws -> SecondaryVideoData {
        do {
            let asset = AVAsset(url: url)
            let durationValue = try await asset.load(.duration)
            return SecondaryVideoData(duration: durationValue.seconds)
        } catch {
            throw VideoMetadataManagerError.cantDecodeMetadata
        }
    }
}


//MARK: - Public

extension VideoMetadataManagerImpl {
    
    public func loadMetadataForVideo(withURL url: URL) async throws -> VideoMetadata {
        do {
            let primaryData = loadPrimaryMetadata(url)
            let secondaryData = try await loadSecondaryMetadata(url)
            return VideoMetadata(
                primary: primaryData,
                secondary: secondaryData
            )
        } catch {
            throw VideoMetadataManagerError.cantReturnMetadata
        }
    }
}
