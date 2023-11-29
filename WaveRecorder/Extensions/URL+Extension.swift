//
//  URL+Extension.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import Foundation

extension URL {
    
    // Create custom folder with file in documents in Documents
    static func createNewDirPath(
        withDirectoryName dirName: String,
        fileName fName: String,
        formatName format: String
    ) -> URL {
//        let dirPath = "file://\(dirName)" // for full custom
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
    
    // Documents folder in device
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return paths[0]
    }
}
