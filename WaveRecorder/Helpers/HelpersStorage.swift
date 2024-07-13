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
    var notificationCenter: NotificationCenter { get }
    var fileManager: FileManager { get }
}

// MARK: - Impl
final class HelpersStorageImpl: HelpersStorage {

    /// Self created
    private(set) var formatter: FormatterProtocol = FormatterImpl()

    /// Default
    private(set) var notificationCenter: NotificationCenter = NotificationCenter.default
    private(set) var fileManager: FileManager = FileManager.default
}
