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
    func fetchRecords(compleiton: @escaping (Result<[AudioRecord], AudioRepositoryError>) -> Void)
    func search(withText text: String, compleiton: @escaping (Result<[AudioRecord], AudioRepositoryError>) -> Void)
    func rename(record: AudioRecord, newName: String, completion: @escaping (Result<Bool, AudioRepositoryError>) -> Void)
    func delete(record: AudioRecord, completion: @escaping (Result<Bool, AudioRepositoryError>) -> Void)
}


//MARK: - Error

enum AudioRepositoryError: Error {
    case cantFetchRecords
    case cantFetchRecord
    case cantDecodeRecord
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


//MARK: - Public

extension AudioRepositoryImpl {
  
    func fetchRecords(compleiton: @escaping (Result<[AudioRecord], AudioRepositoryError>) -> Void) {
       
        // Get list of files
        var files = audioPathManager.getStoredFilesList()
        files.removeFirst() // temp handling of .DS_Store
        
        // Get assets
        let assets = files.compactMap { AVAsset(url: $0) }
        os_log("☑️ List of assets: \(assets)")

        // Extracting metadata from assets
        assets.map { asset in
            
            asset.loadMetadata(for: .id3Metadata) { metadataItems, error in
                
                guard error == nil else {
                    os_log("🚨 ERROR: Loading id3Metadata error \(error)")
                    return
                }
                
                // empty !??!??!
                print("𝍂 Metadata items: \(metadataItems)")
            }
            
        }
    }
    
    func search(withText text: String, compleiton: @escaping (Result<[AudioRecord], AudioRepositoryError>) -> Void) {
        
    }
    
    func rename(record: AudioRecord, newName: String, completion: @escaping (Result<Bool, AudioRepositoryError>) -> Void) {
        
    }
    
    func delete(record: AudioRecord, completion: @escaping (Result<Bool, AudioRepositoryError>) -> Void) {
        
    }
}
