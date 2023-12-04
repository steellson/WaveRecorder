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
    var date: Date
    var duration: TimeInterval?
    var path: String?
    
    init(
        name: String,
        date: Date,
        duration: TimeInterval?,
        path: String?
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.date = date
        self.duration = duration
        self.path = path
    }

}
