//
//  VideoRecord.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 19.02.2024.
//

import AVFoundation

//MARK: - Video Record

struct VideoRecord {
    
    let name: String
    let url: URL
    let duration: TimeInterval
    let frames: [CGImage]?
    
    init(
        name: String,
        url: URL,
        duration: TimeInterval,
        frames: [CGImage]? = nil
    ) {
        self.name = name
        self.url = url
        self.duration = duration
        self.frames = frames
    }
}
