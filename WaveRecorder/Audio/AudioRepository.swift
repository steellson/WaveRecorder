//
//  AudioRepository.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 17.01.2024.
//

import AVFoundation
import OSLog


//MARK: - Protocol

protocol AudioRepository: AnyObject {
    func fetchRecords() async throws -> [AudioRecord]
    func search(withText text: String) async throws -> [AudioRecord]
    func rename(record: AudioRecord, newName: String) async throws
    func delete(record: AudioRecord) async throws
}


//MARK: - Error

enum AudioRepositoryError: Error {
    case cantFetchRecords
    case cantFetchRecord
    case cantDecodeRecord
    case cantDecodeMetadata
    case cantRenameRecord
    case cantDeleteRecord
}


//MARK: - Impl

final class AudioRepositoryImpl: AudioRepository {
  
    private let audioPathManager: AudioPathManager
    
    init() {
        self.audioPathManager = AudioPathManagerImpl()
    }
}


//MARK: - Private

private extension AudioRepositoryImpl {
    
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


//MARK: - Public

extension AudioRepositoryImpl {
  
    func fetchRecords() async throws -> [AudioRecord] {
        do {
            let metadata = try await loadMetadataList()
            return try metadata.map {
                
                let format = $0.primary.format
                let avalibleFormats = AudioFormat.allCases
                
                guard
                    let safeFormat = avalibleFormats.first(where: { $0.rawValue == format })
                else {
                    os_log("ERROR: Cant decode audio format!")
                    throw AudioRepositoryError.cantDecodeMetadata
                }
                
                return AudioRecord(
                    name: $0.primary.name,
                    format: safeFormat,
                    date: $0.secondary.date,
                    duration: $0.secondary.duration
                )
            }
        } catch {
            os_log("ERROR: Cant fetch records!")
            throw AudioRepositoryError.cantFetchRecords
        }
    }
    
    
    func search(withText text: String) async throws -> [AudioRecord] {
        []
    }
    
    func rename(record: AudioRecord, newName: String) async throws {
        
    }
    
    func delete(record: AudioRecord) async throws {
        
    }
}
