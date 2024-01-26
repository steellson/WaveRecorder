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
            let searched = metadata.filter {
                $0.primary.name.components(separatedBy: ".").dropLast().joined().contains(text)
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
        do {
            let metadata = try await audioMetadataManager.loadMetadataList()
            let searchedResults = metadata.filter { $0.primary.name == record.name }
            
            guard
                !searchedResults.isEmpty,
                !(searchedResults.count > 1),
                let result = searchedResults.first
            else {
                os_log("ERROR: Cant rename record!")
                throw AudioRepositoryError.cantRenameRecord
            }
  
            let namePath = "\(newName).\(record.format.rawValue)"
            let isRewrited = audioMetadataManager.rewrite(
                url: result.secondary.url,
                withNewPath: namePath
            )
            
            guard isRewrited else {
                os_log("ATTENTION: Record isn't renamed!")
                throw AudioRepositoryError.cantRenameRecord
            }
            os_log("SUCCESS: Record renamed!")
            
        } catch {
            os_log("ERROR: Cant rename records!")
            throw AudioRepositoryError.cantFetchRecords
        }
    }
    
    func delete(record: AudioRecord) async throws {
        
    }
}
