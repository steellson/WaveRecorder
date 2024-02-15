//
//  AudioMetadata.swift
//
//
//  Created by Andrew Steellson on 15.02.2024.
//

import Foundation


//MARK: - Metadata

public struct PrimaryAudioData {
    
    public let name: String
    public let format: String
    
    public init(
        name: String,
        format: String
    ) {
        self.name = name
        self.format = format
    }
}

public struct SecondaryAudioData {
    
    public let date: Date
    public let duration: TimeInterval
    public let url: URL
    
    public init(
        date: Date,
        duration: TimeInterval,
        url: URL
    ) {
        self.date = date
        self.duration = duration
        self.url = url
    }
}

public struct AudioMetadata {
    
    public let primary: PrimaryAudioData
    public let secondary: SecondaryAudioData
    
    public init(
        primary: PrimaryAudioData,
        secondary: SecondaryAudioData
    ) {
        self.primary = primary
        self.secondary = secondary
    }
}

