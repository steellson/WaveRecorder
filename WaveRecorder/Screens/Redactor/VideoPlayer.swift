//
//  VideoPlayer.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 13.02.2024.
//

import AVFoundation


//MARK: - Protocol

protocol VideoPlayer: AnyObject {
    func getThumbnailImage(forUrl url: URL) throws -> CGImage?
}


//MARK: - Error

enum VideoPlayerError: Error {
    case cantGetThumbnailImage
}


//MARK: - Impl

final class VideoPlayerImpl: VideoPlayer {
    
    func getThumbnailImage(forUrl url: URL) throws -> CGImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTimeMake(value: 1, timescale: 60)
        
        do {
            return try imageGenerator.copyCGImage(
                at: time,
                actualTime: nil
            )
        } catch {
            throw VideoPlayerError.cantGetThumbnailImage
        }
    }
    
    
}
