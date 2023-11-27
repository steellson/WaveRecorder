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
    
    @Attribute(.unique) var id: UUID
    var name: String
    var duration: Int
    var date: Date
    
    init(
        id: UUID,
        name: String,
        duration: Int,
        date: Date
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.date = date
    }

}
