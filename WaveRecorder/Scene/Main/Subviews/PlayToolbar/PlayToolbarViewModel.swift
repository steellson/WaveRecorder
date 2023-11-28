//
//  PlayToolbarViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation

//MARK: - Protocol

protocol PlayToolbarViewModelProtocol: AnyObject {
    var record: Record? { get }
    
    func goBack()
    func play()
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class PlayToolbarViewModel: PlayToolbarViewModelProtocol {
    
    var record: Record?
    
    private let storageService: StorageServiceProtocol
    
    init(
        storageService: StorageServiceProtocol,
        record: Record? = nil
    ) {
        self.storageService = storageService
        self.record = record
    }
    
}


//MARK: - Public

extension PlayToolbarViewModel {
    
    func goBack() {
        print("Go back")
    }
    
    func play() {
        print("Play")
    }
    
    func goForward() {
        print("Go forward")
    }
    
    func deleteRecord() {
        print("Deleted")
    }
}
