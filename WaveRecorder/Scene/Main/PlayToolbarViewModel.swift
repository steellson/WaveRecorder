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
         
    }
}
