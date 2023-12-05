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
    
    @Attribute(.unique)  var name: String
    var date: Date
    var format: String?
    var duration: TimeInterval?
    var path: URL?
    
    init(
        name: String,
        date: Date,
        format: String?,
        duration: TimeInterval?,
        path: URL?
    ) {
        self.name = name
        self.date = date
        self.format = format
        self.duration = duration
        self.path = path
    }

}
