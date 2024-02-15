//
//  VideoFrameGenerator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.02.2024.
//

import AVFoundation


typealias VideoFrame = CGImage


//MARK: - Protocol

protocol VideoFrameGenerator: AnyObject {
    func getAllFrames(forVideoWithUrl url: URL) async throws -> [VideoFrame]
}

//MARK: - Error

enum VideoFrameGeneratorError: Error {
    case cantGetFrameFromSecond
    case cantGetFramesFromVideoWithUrl(String)
    case cantCallImageAssetGenerator
    case cantGetFramesWithZeroSeconds
}

//MARK: - Impl

final class VideoFrameGeneratorImpl: VideoFrameGenerator {
    
    private var prefferedTimesacle: Int32 = 600
    private var generator: AVAssetImageGenerator?
    private var frames = [VideoFrame]()
    
    init(
        prefferedTimesacle: Int32 = 600
    ) {
        self.prefferedTimesacle = prefferedTimesacle
    }
}

//MARK: - Public

extension VideoFrameGeneratorImpl {
    
    func getAllFrames(forVideoWithUrl url: URL) async throws -> [VideoFrame] {
        do {
            let asset: AVAsset = AVAsset(url: url)
            let trackTime = try await asset.load(.duration)
            let seconds = Int(trackTime.seconds)
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            self.generator = generator
            self.frames = []
            
            try fillUpFrames(withTimeInSeconds: seconds)
            
            self.generator = nil
            return frames
        } catch {
            throw VideoFrameGeneratorError.cantGetFramesFromVideoWithUrl(url.path())
        }
    }
}

//MARK: - Private

private extension VideoFrameGeneratorImpl {
    
    func getFrame(fromSecond second: Double) throws -> CGImage {
       let time = CMTimeMakeWithSeconds(second, preferredTimescale: prefferedTimesacle)
       
       do {
           guard
               let image = try self.generator?.copyCGImage(at: time, actualTime: nil)
           else {
               throw VideoFrameGeneratorError.cantCallImageAssetGenerator
           }
           return image
       } catch {
           throw VideoFrameGeneratorError.cantGetFrameFromSecond
       }
   }
    
    func fillUpFrames(withTimeInSeconds seconds: Int) throws {
        guard seconds != 0 else {
            throw VideoFrameGeneratorError.cantGetFramesWithZeroSeconds
        }
        
        for second in 0 ..< seconds {
            let frame = try self.getFrame(fromSecond: Double(second))
            frames.append(frame)
        }
    }
}
