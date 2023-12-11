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
    var isPlaying: Bool { get }
    
    func isRecordEditingStarted(_ isStarted: Bool, newName name: String?)
    
    func goBack()
    func play()
    func pause()
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {

    var record: Record?
    
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
        
        audioService.play(record: record) { [weak self] isStarted in
            self?.isPlaying = isStarted
        }
    }
    
    func pause() {
        guard 
            isPlaying
        else {
            print("ERROR: Cant pause audio")
            return
        }
        
        audioService.pause() { [weak self] isPaused in
            self?.isPlaying = isPaused
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
}
