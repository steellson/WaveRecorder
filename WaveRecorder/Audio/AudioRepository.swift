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
    case cantHandleFormat
}


//MARK: - Impl

final class AudioRepositoryImpl: AudioRepository {
  
    private let audioMetadataManager: AudioMetadataManager
    
    init() {
        self.audioMetadataManager = AudioMetadataManagerImpl()
    }
}


//MARK: - Private

private extension AudioRepositoryImpl {
    
    func handleStringFormat(_ format: String) -> AudioFormat {
        let avalibleFormats = AudioFormat.allCases
        let defaultFormat = AudioFormat.m4a
        return avalibleFormats.first(where: { $0.rawValue == format }) ?? defaultFormat
    }
}


//MARK: - Public

extension AudioRepositoryImpl {
  
    func fetchRecords() async throws -> [AudioRecord] {
        do {
            let metadata = try await audioMetadataManager.loadMetadataList()
            return metadata.map {
                AudioRecord(
                    name: $0.primary.name,
                    format: handleStringFormat($0.primary.format),
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
        do {
            let metadata = try await audioMetadataManager.loadMetadataList()
            let searched = metadata.compactMap {
                $0.primary.name.components(separatedBy: ".").dropLast().joined().contains(text) ? $0 : nil
            }
            return searched.map {
                AudioRecord(
                    name: $0.primary.name,
                    format: handleStringFormat($0.primary.format),
                    date: $0.secondary.date,
                    duration: $0.secondary.duration
                )
            }
        } catch {
            os_log("ERROR: Cant search and fetch records!")
            throw AudioRepositoryError.cantFetchRecords
        }
    }
    
    func rename(record: AudioRecord, newName: String) async throws {
        
    }
    
    func delete(record: AudioRecord) async throws {
        
    }
}
