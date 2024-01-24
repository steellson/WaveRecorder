//
//  AudioMetadataManager.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.01.2024.
//

import AVFoundation
import OSLog


//MARK: - Protocol

protocol AudioMetadataManager: AnyObject {
    func loadMetadataList() async throws -> [AudioMetadata]
}


//MARK: - Impl

final class AudioMetadataManagerImpl: AudioMetadataManager {
    
    private let audioPathManager: AudioPathManager
    
    init() {
        self.audioPathManager = AudioPathManagerImpl()
    }
}


//MARK: - Private

private extension AudioMetadataManagerImpl {
    
    func loadListOfUrls() -> [URL] {
        var list = audioPathManager.getStoredFilesList()
        list.removeFirst() // Exclude .DS_Store
        return list
    }
    
    
    func loadPrimaryAudioData(fromURLs urls: [URL]) -> [PrimaryAudioData] {
        urls.map { url in
            PrimaryAudioData(
                name: url.lastPathComponent,
                format: url.pathExtension
            )
        }
    }
    
    func loadSecondaryAudioData(fromAssets assets: [AVAsset]) async throws -> [SecondaryAudioData] {
        do {
            return try await assets.asyncMap { asset in
                
                let dateValue = try await asset.load(.creationDate)?.load(.value)
                let durationValue = try await asset.load(.duration)
                
                guard let date = dateValue as? Date else {
                    os_log("ERROR: Cant parse asset Date!")
                    throw AudioRepositoryError.cantDecodeMetadata
                }
                
                return SecondaryAudioData(
                    date: date,
                    duration: TimeInterval(floatLiteral: durationValue.seconds)
                )
            }
        } catch {
            os_log("ERROR: Something went wrong! Asset couldnt be parsed")
            throw AudioRepositoryError.cantDecodeMetadata
        }
    }
}


//MARK: - Public

extension AudioMetadataManagerImpl {
    
    func loadMetadataList() async throws -> [AudioMetadata] {
        let urls = loadListOfUrls()
        let assets = urls.compactMap { AVAsset(url: $0) }
        
        let primaryAudioData = loadPrimaryAudioData(fromURLs: urls)
        let secondaryAudioData = try await loadSecondaryAudioData(fromAssets: assets)
        
        return assets.enumerated().compactMap { index, _ in
            AudioMetadata(
                primary: primaryAudioData[index],
                secondary: secondaryAudioData[index]
            )
        }
    }
}
