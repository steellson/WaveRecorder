//
//  Helpers.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 16.01.2024.
//

import Foundation

//MARK: - Protocol

protocol HelpersStorage: AnyObject {
    var formatter: FormatterProtocol { get }
    var timeRefresher: TimeRefresherProtocol { get }
    var notificationCenter: NotificationCenter { get }
    var fileManager: FileManager { get }
}

final class HelpersStorageImpl: HelpersStorage {
    
    //MARK: Self created
    private(set) var formatter: FormatterProtocol = FormatterImpl()
    private(set) var timeRefresher: TimeRefresherProtocol = TimeRefresher()
    
    //MARK: Default
    private(set) var notificationCenter: NotificationCenter = NotificationCenter.default
    private(set) var fileManager: FileManager = FileManager.default
}
