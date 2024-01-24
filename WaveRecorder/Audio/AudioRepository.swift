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
  
    private let audioMetadataManager: AudioMetadataManager
    
    init() {
        self.audioMetadataManager = AudioMetadataManagerImpl()
    }
}


//MARK: - Public

extension AudioRepositoryImpl {
  
    func fetchRecords() async throws -> [AudioRecord] {
        do {
            let metadata = try await audioMetadataManager.loadMetadataList()
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
