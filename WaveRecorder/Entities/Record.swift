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
    
    @Attribute(.unique) var id: String
    var name: String
    var duration: TimeInterval
    var date: Date
    
    init(
        name: String,
        duration: TimeInterval,
        date: Date
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.duration = duration
        self.date = date
    }

}
