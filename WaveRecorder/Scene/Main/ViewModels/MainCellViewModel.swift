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
    
    var onPlaying: ((Bool) -> Void)? { get set }
    var onFinish: ((Bool) -> Void)? { get set }
    
    var isPlaying: Bool { get }
    
    func goBack()
    func play(atTime time: Float?)
    func stop()
    func goForward()
    func deleteRecord()
    func rename(withNewName name: String)
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {

    var record: Record?
    
    var onPlaying: ((Bool) -> Void)?
    var onFinish: ((Bool) -> Void)?
    
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
    
    func play(atTime time: Float?) {
        guard
            let record
        else {
            print("ERROR: Cant play audio!")
            onPlaying?(false)
            return
        }
        
        audioService.play(record: record, onTime: time) { [weak self] isPlaying in
            self?.isPlaying = isPlaying
            
            DispatchQueue.main.async {
                self?.onPlaying?(isPlaying)
            }
        }
    }
    
    func stop() {
        guard 
            isPlaying
        else {
            print("ERROR: Cant stop audio")
            onFinish?(false)
            return
        }
        
        audioService.stop() { [weak self] isStopped in
            self?.isPlaying = !isStopped
            
            DispatchQueue.main.async {
                self?.onFinish?(isStopped)
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
