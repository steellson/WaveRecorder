//
//  PlayViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation


//MARK: - Protocol

protocol PlayViewModelProtocol: AnyObject {
    var onPlaying: ((Bool) -> Void)? { get set }
    var onFinish: ((Bool) -> Void)? { get set }
    
    var recordDuration: Float { get }
    var isPlaying: Bool { get }
        
    func goBack()
    func play(atTime time: Float?)
    func stop()
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class PlayViewModel: PlayViewModelProtocol {
    
    var onPlaying: ((Bool) -> Void)?
    var onFinish: ((Bool) -> Void)?
    
    var recordDuration: Float {
        Float(record.duration ?? 0)
    }
    
    private(set) var isPlaying = false
    
    private let record: Record

    private weak var parentViewModel: MainCellViewModelProtocol?
    private let audioService: AudioServiceProtocol

    
    init(
        parentViewModel: MainCellViewModelProtocol,
        audioService: AudioServiceProtocol,
        record: Record
    ) {
        self.parentViewModel = parentViewModel
        self.audioService = audioService
        self.record = record
    }
}


//MARK: - Public

extension PlayViewModel {
    
    func goBack() {
        print("Go back tapped")
    }
    
    func play(atTime time: Float?) {
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
        parentViewModel?.deleteRecord() { }
    }
}
