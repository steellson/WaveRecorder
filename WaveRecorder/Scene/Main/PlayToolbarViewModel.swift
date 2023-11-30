//
//  PlayToolbarViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation

//MARK: - Protocol

protocol PlayToolbarViewModelProtocol: AnyObject {
    var record: Record? { get set }
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
    private weak var parentViewModel: MainViewModelProtocol?

    
    init(
        audioService: AudioServiceProtocol,
        parentViewModel: MainViewModelProtocol,
        record: Record? = nil
    ) {
        self.audioService = audioService
        self.parentViewModel = parentViewModel
        self.record = record
    }
    
    private func getNumberOfRecords() -> Int {
        guard let parentViewModel else { return 0 }
        let count = parentViewModel.records.count + 1
        
        return count
    }
    
    private func setupRecord() {
        let numberOfRecord = getNumberOfRecords()
        let nameOfRecord = "Record \(numberOfRecord)"
        
    }
}


//MARK: - Public

extension PlayToolbarViewModel {
    
    func goBack() {
        print("Go back")
    }
    
    func playPause() {
        setupRecord()
        
        guard let record else {
            print("ERROR: Cant play record / Reason: nil")
            return
        }
        
        if isPaused {
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
        guard let record,
              let parentViewModel
        else {
            print("ERROR: Cant delete record!")
            return
        }
        parentViewModel.deleteRecord(withID: record.id, completion: nil)
    }
}
