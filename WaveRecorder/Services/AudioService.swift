//
//  AudioService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation


//MARK: - Protocol

protocol AudioServiceProtocol: AnyObject {
    func play(record: Record, completion: @escaping (Bool) -> Void)
    func pause(completion: @escaping (Bool) -> Void)
}


//MARK: - Impl

final class AudioService: AudioServiceProtocol {
    
    private let fileManagerInstance = FileManager.default
    
    private var audioPlayer: AVAudioPlayer?
}


//MARK: - Private

private extension AudioService {
    
    func setupSettings() {
        guard let audioPlayer = self.audioPlayer else {
            print("ERROR: AudioPlayer is not setted yet!")
            return
        }
        
        audioPlayer.isMeteringEnabled = true
        audioPlayer.numberOfLoops = 0
    }
}


//MARK: - Public

extension AudioService {
    
    //MARK: Play
    
    func play(record: Record, completion: @escaping (Bool) -> Void) {
        let recordURL = URLBuilder.buildURL(
            forRecordWithName: record.name,
            andFormat: record.format
        )
        
        guard
            fileManagerInstance.fileExists(atPath: recordURL.path())
        else {
            print("ERROR: File with name \(record.name) doesn't exist!")
            completion(false)
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            do {

                self.audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                self.setupSettings()
                
                print(">> Will start playing audio with URL: \(recordURL)")
                
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                completion(true)
                
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
                completion(false)
            }
        }
    }

    
    //MARK: Pause
    
    func pause(completion: @escaping (Bool) -> Void) {
        guard self.audioPlayer != nil else {
            print("ERROR: AudioPlayer is not setted yet!")
            completion(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.pause()
            completion(true)
        }
    }
}

