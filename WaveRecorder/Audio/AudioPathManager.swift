//
//  AudioPathManager.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import OSLog


//MARK: - Protocol

protocol AudioPathManager: AnyObject {
    func createURL(forRecordWithName name: String, andFormat format: String) -> URL
    func createAudioRecordName() -> String
    func getStoredFilesList() -> [URL]
    func isFileExist(_ url: URL) -> Bool
}


//MARK: - Impl

final class AudioPathManagerImpl: AudioPathManager {
    
    private let storedFolderName = "WRRecords"
    
    private let fileManager: FileManager
    
    
    init() {
        self.fileManager = FileManager.default
        
        createStoredFolder()
    }
    
    private func createStoredFolder() {
        let storedFolderPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(storedFolderName)
            .path()
        
        if !fileManager.fileExists(atPath: storedFolderPath) {
            do {
                try fileManager.createDirectory(
                    atPath: storedFolderPath,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                os_log(">>> AudioPathManager: Stored folder exist")
            }
        }
    }
}


//MARK: - Public

extension AudioPathManagerImpl {
        
    func createURL(
        forRecordWithName name: String,
        andFormat format: String
    ) -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(storedFolderName)
            .appendingPathComponent(name)
            .appendingPathExtension(format)
    }
    
    
    func createAudioRecordName() -> String {
        let storedFolderPath = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(storedFolderName)
            .path()
        
        let defaultPrefix = "Record-"
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: storedFolderPath)
            
            if !files.isEmpty {
                let maxRecords = files
                    .compactMap { file in
                        if file.hasPrefix(defaultPrefix) {
                            let postfix = file
                                .components(separatedBy: "-")
                                .last
                            return postfix?
                                .components(separatedBy: ".")
                                .first
                        } else {
                            return nil
                        }
                    }
                    .compactMap { Int($0) }
                    .max()
                
                return defaultPrefix + String(((maxRecords ?? 0) + 1))
            }
        } catch {
            return defaultPrefix + String(1)
        }
        return defaultPrefix + String(1)
    }
    
    
    //MARK: Get
    
    func getStoredFilesList() -> [URL] {
        let storedFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(storedFolderName)
        
        do {
            return try fileManager.contentsOfDirectory(at: storedFolderURL, includingPropertiesForKeys: nil)
        } catch {
            os_log("ERROR: Cant file stored folder!")
            return []
        }
    }
    
    
    //MARK: Check
    
    func isFileExist(_ url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path(percentEncoded: false))
    }
}
