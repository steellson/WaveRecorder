//
//  AudioRecord.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 27.11.2023.
//

import Foundation


//MARK: - Format

public enum AudioFormat: String, CaseIterable {
    case m4a
    case mp3
    case flac
}


//MARK: - Record

public struct AudioRecord: Identifiable {
    
    public let id: String
    public let name: String
    public let format: AudioFormat
    public let date: Date
    public var duration: TimeInterval?
    
    public init(
        name: String,
        format: AudioFormat,
        date: Date,
        duration: TimeInterval?
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.format = format
        self.date = date
        self.duration = duration
    }
}

extension AudioRecord: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AudioRecord, rhs: AudioRecord) -> Bool {
        lhs.id == rhs.id
    }
}
