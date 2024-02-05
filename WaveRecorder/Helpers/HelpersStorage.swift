//
//  Helpers.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 16.01.2024.
//

import Foundation

struct HelpersStorage {
    
    //MARK: Self created
    static let formatter: FormatterProtocol = FormatterImpl()
    static let timeRefresher: TimeRefresherProtocol = TimeRefresher()
    
    //MARK: Default
    static let notificationCenter: NotificationCenter = NotificationCenter.default
    static let fileManager: FileManager = FileManager.default
}
