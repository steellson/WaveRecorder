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
    var isPaused: Bool { get set }
    
    func goBack()
    func playPause()
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class PlayToolbarViewModel: PlayToolbarViewModelProtocol {
    
    var record: Record?
    var isPaused = true
    
    private let audioService: AudioServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(
        audioService: AudioServiceProtocol,
        storageService: StorageServiceProtocol,
        record: Record? = nil
    ) {
        self.audioService = audioService
        self.storageService = storageService
        self.record = record
    }
    
}


//MARK: - Public

extension PlayToolbarViewModel {
    
    func goBack() {
        print("Go back")
    }
    
    func playPause() {
        guard let record else {
            print("ERROR: Cant play record / Reason: nil")
            return
        }
        
        if !isPaused {
            audioService.playAudio(withName: record.name)
            isPaused = false
        } else {
            audioService.pauseAudio()
            isPaused = true
        }
    }
    
    func goForward() {
        print("Go forward")
    }
    
    func deleteRecord() {
        guard let record else {
            print("ERROR: Cant play record / Reason: nil")
            return
        }
        
        storageService.deleteRecord(withID: record.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("ERROR: Couldnt delete record \(error)")
            }
        }
    }
}
