//
//  Formatter.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation

final class Formatter {
    
    static let instance = Formatter()
    
    private let dateFormatter = DateFormatter()

    
    private init() {}
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.dateFormat = "d MMM. YYYY"
        return dateFormatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hour = Int(duration) / 3600
        let minute = Int(duration) / 60 % 60
        let second = Int(duration) % 60
        
        return duration > 3600
        ? String(format: "%02i:%02i:%02i", hour, minute, second)
        : String(format: "%02i:%02i", minute, second)
    }
}
