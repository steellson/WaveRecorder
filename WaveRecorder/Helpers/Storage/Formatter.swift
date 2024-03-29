//
//  Formatter.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation


//MARK: - Protocol

protocol FormatterProtocol: AnyObject {
    func formatName(_ name: String) -> String
    func formatDate(_ date: Date) -> String
    func formatDuration(_ duration: TimeInterval) -> String
}


//MARK: - Impl

final class FormatterImpl: FormatterProtocol {
        
    private let dateFormatter = DateFormatter()
    
    
    //MARK: Methods
    
    func formatName(_ name: String) -> String {
       name.components(separatedBy: ".").dropLast().first ?? name
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.dateFormat = "d MMM. YYYY hh:mm"
        return dateFormatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let roundedDuration = duration.rounded(.up)
    
        let hour = Int(roundedDuration) / 3600
        let minute = Int(roundedDuration) / 60 % 60
        let second = Int(roundedDuration) % 60
        
        return duration > 3600
        ? String(format: "%02i:%02i:%02i", hour, minute, second)
        : String(format: "%02i:%02i", minute, second)
    }
}
