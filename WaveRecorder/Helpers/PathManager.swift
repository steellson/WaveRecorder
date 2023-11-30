//
//  PathManager.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 30.11.2023.
//

import Foundation

//MARK: - Impl

final class PathManager {
    
    static let instance = PathManager()
    
    private let fileManagerInstance = FileManager.default
    
    private init() {}
    
    
    //MARK: Helps with get
    
    func getDocumentsDirectory() -> URL {
        let paths = fileManagerInstance.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return paths[0]
    }
    
    func getWRRecordsDirectory() -> URL {
        getDocumentsDirectory().appendingPathExtension("/WRRecords")
    }
    
    func checkExistanceOfFile(withName name: String) -> Bool {
        fileManagerInstance.fileExists(atPath: getWRRecordsDirectory().appendingPathComponent(name).path())
    }
    
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
    
    
    //MARK: Helps with create
    
    func createNewFile(
        withDirectoryName dirName: String,
        fileName fName: String,
        formatName format: String
    ) -> URL {
       // let dirPath = "file://\(dirName)" // for full custom
        
        let documentsPath = String(getDocumentsDirectory().absoluteString.dropLast())
        let pathString = [
            documentsPath,
            dirName,
            fName
        ].joined(separator: "/") + ".\(format)"
        
        let path = URL(string: pathString)
        guard let filePath = path else {
            return getDocumentsDirectory()
        }
        
        return filePath
    }
}
