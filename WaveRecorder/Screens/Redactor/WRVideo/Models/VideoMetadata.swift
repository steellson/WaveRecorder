//
//  VideoMetadata.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 19.02.2024.
//

import Foundation

// MARK: - PrimaryVideoData
public struct PrimaryVideoData {

    public let name: String
    public let url: URL

    public init(
        name: String,
        url: URL
    ) {
        self.name = name
        self.url = url
    }
}

// MARK: - SecondaryVideoData
public struct SecondaryVideoData {

    public let duration: TimeInterval

    public init(
        duration: TimeInterval
    ) {
        self.duration = duration
    }
}

// MARK: - VideoMetadata
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
