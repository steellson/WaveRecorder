//
//  ServiceFactory.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 10.01.2024.
//

import Foundation


//MARK: - Protocols

protocol Service: AnyObject { }

protocol ServiceFactoryProtocol: AnyObject {
    func createService(ofType type: ServiceType) -> Service
}


//MARK: - Type

enum ServiceType {
    case audioService
    case recordService
    case storageService
}


//MARK: - Impl

final class ServiceFactory: ServiceFactoryProtocol {

    private let helpers: Helpers
    
    init(
        helpers: Helpers
    ) {
        self.helpers = helpers
    }

    func createService(ofType type: ServiceType) -> Service {
        switch type {
        case .audioService: AudioService(
            urlBuilder: helpers.urlBuilder,
            fileManager: helpers.fileManager
        )
        case .recordService: RecordService(
            urlBuilder: helpers.urlBuilder,
            fileManager: helpers.fileManager
        )
        case .storageService: StorageService(
            urlBuilder: helpers.urlBuilder,
            fileManager: helpers.fileManager
        )
        }
    }
}
