//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation


//MARK: - Protocols

protocol MainViewModelProtocol: AnyObject {    
    var records: [Record] { get set }
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records: [Record] = []
    
    private let storageService: StorageServiceProtocol
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
    }
}


//MARK: - Public

extension MainViewModel {
 
    
}
