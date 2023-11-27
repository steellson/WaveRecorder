//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation

//MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    var isRecording: Bool { get }
    
    func recButtonDidTapped()
}

//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {

    private(set) var isRecording = false
    
    private let storageService: StorageServiceProtocol
    
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
    }
    
}


//MARK: - Public

extension MainViewModel {
    
    func recButtonDidTapped() {
        isRecording.toggle()
    }
}
