//
//  MainCellViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol MainCellViewModelProtocol: AnyObject {
    var record: Record? { get set }
    
    var onPlaying: ((TimeInterval) -> Void)? { get set }
    var onPause: ((Bool) -> Void)? { get set }
    
    var isPlaying: Bool { get }
    
    func goBack()
    func play()
    func play(onTime time: Float)
    func pause()
    func goForward()
    func deleteRecord()
    func rename(withNewName name: String)
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {

    var record: Record?
    
    var onPlaying: ((TimeInterval) -> Void)?
    var onPause: ((Bool) -> Void)?
    
    private(set) var isPlaying = false
        
    private weak var parentViewModel: MainViewModelProtocol?
    private let audioService: AudioServiceProtocol
    
    
    init(
        parentViewModel: MainViewModelProtocol,
        audioService: AudioServiceProtocol,
        record: Record
    ) {
        self.parentViewModel = parentViewModel
        self.audioService = audioService
        self.record = record
    }
}


//MARK: - Public

extension MainCellViewModel {
    
    func goBack() {
        print("Go back tapped")
    }
    
    func play() {
        guard 
            let record,
            !isPlaying
        else {
            print("ERROR: Cant play audio!")
            return
        }
        
        audioService.play(record: record, onTime: nil) { [weak self] time in
            guard let time else {
                self?.isPlaying = false
                return
            }
            self?.isPlaying = true
            
            DispatchQueue.main.async {
                self?.onPlaying?(time)
            }
        }
    }
    
    func play(onTime time: Float) {
        guard
            let record
        else {
            print("ERROR: Cant play audio!")
            return
        }
        
        if audioService.playerCurrentTime == nil {
            play()
        } else {
            audioService.play(record: record, onTime: time) { [weak self] time in
                let onPause = (time != nil)
                self?.isPlaying = false
                
                DispatchQueue.main.async {
                    self?.onPause?(onPause)
                }
            }
        }
        
    }
    
    func pause() {
        guard 
            isPlaying
        else {
            print("ERROR: Cant pause audio")
            return
        }
        
        audioService.stop() { [weak self] isPaused in
            self?.isPlaying = !isPaused
            
            DispatchQueue.main.async {
                self?.onPause?(isPaused)
            }
        }
    }
    
    func goForward() {
        print("Go forward tapped")
    }
    
    func deleteRecord() {
        guard 
            let record,
            let parentViewModel
        else {
            print("ERROR: Cant delete record")
            return
        }
        
        parentViewModel.delete(record: record)
    }
    
    func isRecordEditingStarted(_ isStarted: Bool, newName name: String?) {
        guard
            let record,
            let parentViewModel,
            let name
        else {
            print("ERROR: Cant edit audio record!")
            return
        }
 
        parentViewModel.renameRecord(record, newName: name)
    }
    
    func rename(withNewName name: String) {
        guard let record else {
            print("ERROR: Cant rename audio! Reason: audio is nil")
            return
        }
        
        parentViewModel?.renameRecord(record, newName: name)
    }
}
