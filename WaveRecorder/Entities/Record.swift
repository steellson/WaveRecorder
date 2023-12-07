//
//  Record.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 27.11.2023.
//

import Foundation
import SwiftData

@Model
final class Record {
    
    @Attribute(.unique) let id: String
    var name: String
    var date: Date
    var format: String
    var duration: TimeInterval?
    
    init(
        name: String,
        date: Date,
        format: String,
        duration: TimeInterval?
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.date = date
        self.format = format
        self.duration = duration
    }

}
