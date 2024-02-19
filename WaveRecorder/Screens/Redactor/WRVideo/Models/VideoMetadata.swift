//
//  VideoMetadata.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 19.02.2024.
//

import Foundation


//MARK: - Metadata

public struct PrimaryVideoData {
    
    let name: String
    let url: URL
    
    init(
        name: String,
        url: URL
    ) {
        self.name = name
        self.url = url
    }
}

public struct SecondaryVideoData {
    
    let duration: TimeInterval
    
    init(
        duration: TimeInterval
    ) {
        self.duration = duration
    }
}

public struct VideoMetadata {
    
    public let primary: PrimaryVideoData
    public let secondary: SecondaryVideoData
    
    public init(
        primary: PrimaryVideoData,
        secondary: SecondaryVideoData
    ) {
        self.primary = primary
        self.secondary = secondary
    }
}

