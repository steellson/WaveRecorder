//
//  MainCellViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation

//MARK: - Protocol

protocol MainCellViewModelProtocol: AnyObject {
    var record: Record { get }
    var isPaused: Bool { get set }
    
    func goBack()
    func playPause(completion: @escaping (Bool) -> Void)
    func goForward()
    func delete(completion: @escaping (Bool) -> Void)
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {
    
    var record: Record
    var isPaused = true
    
    private let audioService: AudioServiceProtocol
    private weak var parentViewModel: MainViewModelProtocol?

    
    init(
        audioService: AudioServiceProtocol,
        parentViewModel: MainViewModelProtocol,
        record: Record
    ) {
        self.audioService = audioService
        self.parentViewModel = parentViewModel
        self.record = record
    }
}


//MARK: - Public

extension MainCellViewModel {
    
    func goBack() {
        print("Go back")
    }
    
    func playPause(completion: @escaping (Bool) -> Void) {
        if isPaused {
            audioService.play(audioRecord: record) { [weak self] error in
                guard let error else {
                    self?.isPaused = false
                    completion(true)
                    return
                }
                completion(false)
                print("ERROR: Cant play record \(error)")
            }
        } else {
            audioService.pause(audioRecord: record) { [weak self] error in
                guard let error else {
                    self?.isPaused = true
                    completion(true)
                    return
                }
                completion(false)
                print("ERROR: Cant pause record \(error)")
            }
        }
    }
     
    func goForward() {
        print("Go forward")
    }
    
    func delete(completion: @escaping (Bool) -> Void) {
        guard let parentVM = parentViewModel else {
            print("ERROR: Cant delete record by the reason of parent viewModel unfounded")
            completion(false)
            return
        }
        parentVM.didDeleted(record: record)
    }
}
