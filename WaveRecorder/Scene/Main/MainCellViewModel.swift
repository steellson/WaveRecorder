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
    
    func goBack()
    func playPause()
    func goForward()
    func deleteRecord()
    
    func isRecordEditingStarted(_ isStarted: Bool, newName name: String?)
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {

    var record: Record?
    
    private let fileManagerInstance = FileManager.default
    
    private weak var parentViewModel: MainViewModelProtocol?
    
    private(set) var isPlaying = false
        
    private var audioPlayer: AVAudioPlayer?
    
    
    init(
        parentViewModel: MainViewModelProtocol
    ) {
        self.parentViewModel = parentViewModel
    }
}


//MARK: - Public

extension MainCellViewModel {
    
    func goBack() {
        print("Go back tapped")
    }
    
    func playPause() {
        guard let record else {
            print("ERROR: Record is not setted!")
            return
        }
        
        isPlaying ? pause() : play(record: record)
    }
    
    func goForward() {
        print("Go forward tapped")
    }
    
    func deleteRecord() {
        guard 
            let record,
            let parentVM = parentViewModel 
        else {
            print("ERROR: MainCellViewModel is not finally configured")
            return
        }
        
        parentVM.delete(record: record)
    }
    
    func isRecordEditingStarted(_ isStarted: Bool, newName name: String?) {
        guard
            let record,
            let parentVM = parentViewModel
        else {
            print("ERROR: MainCellViewModel is not finally configured")
            return
        }
        
        if let name {
            parentVM.renameRecord(record, newName: name)
        }
    }
}

//MARK: - Private

private extension MainCellViewModel {
    
    func setupSettings() {
        guard let audioPlayer = self.audioPlayer else {
            print("ERROR: AudioPlayer is not setted yet!")
            return
        }
        
        audioPlayer.isMeteringEnabled = true
        audioPlayer.numberOfLoops = 0
    }
    
    
    //MARK: Play
    
    func play(record: Record) {
        let recordURL = fileManagerInstance.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(record.name)
            .appendingPathExtension(record.format)
        
        guard
            fileManagerInstance.fileExists(atPath: recordURL.path())
        else {
            print("ERROR: File with name \(record.name) doesn't exist!")
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            do {
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                self.setupSettings()
                
                print(">> Will start playing audio with URL: \(recordURL)")
                
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.isPlaying = true
                
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
            }
        }
    }

    
    //MARK: Pause
    
    func pause() {
        guard self.audioPlayer != nil else {
            print("ERROR: AudioPlayer is not setted yet!")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.pause()
            self?.isPlaying = false
        }
    }
}
