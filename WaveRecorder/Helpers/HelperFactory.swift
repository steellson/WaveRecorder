//
//  HelperFactory.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 16.01.2024.
//

import Foundation


//MARK: - Protocols

protocol Helper: AnyObject { }

protocol HelperFactory: AnyObject {
    func createHelper(ofType type: HelperType) -> Helper
}


//MARK: - Type

enum HelperType {
    case fileManager
    case notificationCenter
    case formatter
    case timeRefresher
}


//MARK: - Impl

final class HelperFactoryImpl: HelperFactory {
    
    private let fileManager: FileManager = FileManager.default
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    private let formatter: FormatterProtocol = FormatterImpl()
    private let timeRefresher: TimeRefresherProtocol = TimeRefresher()
    

    func createHelper(ofType type: HelperType) -> Helper {
        switch type {
        case .fileManager: return fileManager
        case .notificationCenter: return notificationCenter
        case .formatter: return formatter
        case .timeRefresher: return timeRefresher
        }
    }
}
