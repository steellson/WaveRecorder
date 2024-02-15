//
//  AudioPathManager.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import OSLog


//MARK: - Protocol

public protocol AudioPathManager: AnyObject {
    func createURL(forRecordWithName name: String, andFormat format: String) -> URL
    func createAudioRecordName() -> String
    func getStoredFilesList() -> [URL]
    func isFileExist(_ url: URL) -> Bool
    func moveItem(fromURL: URL, toURL: URL) -> Bool
    func removeItem(withURL url: URL) -> Bool
}


//MARK: - Impl

final public class AudioPathManagerImpl: AudioPathManager {
    
    private let storedFolderName = "WRRecords"
    
    private let fileManager: FileManager
    
    
    public init() {
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


public extension AudioPathManagerImpl {
    
    //MARK: Create
        
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
    
    
    //MARK: Move
    
    func moveItem(fromURL: URL, toURL: URL) -> Bool {
        try? fileManager.moveItem(at: fromURL, to: toURL)
        guard 
            fileManager.fileExists(atPath: toURL.path(percentEncoded: false))
        else {
            os_log("ERROR: Item cant be replaced")
            return false
        }
        return true
    }
    
    
    //MARK: Remove
    
    func removeItem(withURL url: URL) -> Bool {
        try? fileManager.removeItem(at: url)
        guard
            !fileManager.fileExists(atPath: url.path(percentEncoded: false))
        else {
            os_log("ERROR: Item cant be deleted")
            return false
        }
        return true
    }
}
