//
//  AudioRecord.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 27.11.2023.
//

import Foundation


//MARK: - Format

enum AudioFormat: String {
    case m4a
    case mp3
    case aac
}


//MARK: - Record

struct AudioRecord: Identifiable {
    
    let id: String
    let name: String
    let format: AudioFormat
    let date: Date
    var duration: TimeInterval?
    
    init(
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

