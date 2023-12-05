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
    
    @Attribute(.unique) var name: String
    var date: Date
    var path: String?
    var duration: TimeInterval?
    
    init(
        name: String,
        date: Date,
        path: String?,
        duration: TimeInterval
    ) {
        self.name = name
        self.date = date
        self.path = path
        self.duration = duration
    }

}
