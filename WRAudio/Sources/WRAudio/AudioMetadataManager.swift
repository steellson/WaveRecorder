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
    func rewrite(url: URL, withNewPath newName: String) -> Bool
    func destroyFile(withURL url: URL) -> Bool
}


//MARK: - Impl

final public class AudioMetadataManagerImpl: AudioMetadataManager {
    
    private let audioPathManager: AudioPathManager
    
    public init() {
        self.audioPathManager = AudioPathManagerImpl()
    }
}


//MARK: - Private

private extension AudioMetadataManagerImpl {
    
    func loadListOfUrls() -> [URL] {
        let list = audioPathManager.getStoredFilesList()
        let excluded = ".DS_Store"
        let filtered = list.filter { !($0.lastPathComponent == excluded) }
        return filtered
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
            return try await assets.enumerated().asyncMap { index, asset in
                
                let dateValue = try await asset.load(.creationDate)?.load(.value)
                let durationValue = try await asset.load(.duration)
                let url = loadListOfUrls()[index]
      
                guard let date = dateValue as? Date else {
                    os_log("ERROR: Cant parse asset Date!")
                    throw AudioRepositoryError.cantDecodeMetadata
                }
                
                return SecondaryAudioData(
                    date: date,
                    duration: TimeInterval(floatLiteral: durationValue.seconds),
                    url: url
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
    
    public func rewrite(url: URL, withNewPath newName: String) -> Bool {
        audioPathManager.moveItem(
            fromURL: url,
            toURL: url.deletingLastPathComponent().appendingPathComponent(newName)
        )
    }
    
    public func destroyFile(withURL url: URL) -> Bool {
        audioPathManager.removeItem(withURL: url)
    }
}
