//
//  ServiceFactory.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 10.01.2024.
//

import Foundation


//MARK: - Protocols

protocol Service: AnyObject { }

protocol ServiceFactory: AnyObject {
    func createService(ofType type: ServiceType) -> Service
}


//MARK: - Type

enum ServiceType {
    case audioService
    case recordService
    case storageService
}


//MARK: - Impl

final class ServiceFactoryImpl: ServiceFactory {

    private let helperFactory: HelperFactory
    
    init(
        helperFactory: HelperFactory
    ) {
        self.helperFactory = helperFactory
    }

    func createService(ofType type: ServiceType) -> Service {
        let urlBuilder = helperFactory.createHelper(ofType: .urlBuilder) as! URLBuilder
        let fileManager = helperFactory.createHelper(ofType: .fileManager) as! FileManager
    
        switch type {
        case .audioService: return AudioService(
            urlBuilder: urlBuilder,
            fileManager: fileManager
        )
        case .recordService: return RecordService(
            urlBuilder: urlBuilder,
            fileManager: fileManager
        )
        case .storageService: return StorageService(
            urlBuilder: urlBuilder,
            fileManager: fileManager
        )
        }
    }
}
