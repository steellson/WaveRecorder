//
//  Pather.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 06.12.2023.
//

import Foundation

final class Pather {
    
    static let instance = Pather()
    
    private let fileManagerInstance = FileManager.default
    
    private init() {}
    
    
    func isFileExists(withDirectoryName
                      dirName: String, 
                      withName name: String,
                      andFormat format: String) -> Bool {
        fileManagerInstance
            .fileExists(atPath: getFolderInDocumentsDirectory(withName: dirName)
                .appendingPathComponent(name)
                .appendingPathExtension(format)
                .path())
    }
    
    
    //MARK: Get
    
    func getDocumentsDirectory() -> URL {
        FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getFolderInDocumentsDirectory(withName name: String) -> URL {
        getDocumentsDirectory()
            .appendingPathComponent(name)
    }
    
    
    //MARK: Set
    
    func createFolder(withDirectoryName name: String) {
        let directoryURL = getDocumentsDirectory().appendingPathComponent(name)
        let directoryPath = directoryURL.path(percentEncoded: true)
        
        if !fileManagerInstance.fileExists(atPath: directoryPath) {
                do {
                    try fileManagerInstance.createDirectory(atPath: directoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("ERROR: Creating folder in documents dir: \(error)")
                }
            }
    }
    
    func createNewFilePath(withDirectoryName dirName: String,
                           fileName fName: String,
                           formatName format: String) -> URL {

        let url = getFolderInDocumentsDirectory(withName: dirName) 
            .appendingPathComponent(fName)
            .appendingPathExtension(format)
        
        if fileManagerInstance.isReadableFile(atPath: url.path()) {
            print(">>> PATHER: URL CREATED \(url)")
            return url
        } else {
            print(">>> ATTENTION !!! File with created url is already exists. URL: \(url)")
            return url
        }
    }
}
