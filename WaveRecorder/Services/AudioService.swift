//
//  AudioService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation


//MARK: - Protocol

protocol AudioServiceProtocol: AnyObject {
    var playerCurrentTime: TimeInterval? { get }
    
    func play(record: Record, onTime time: Float?, completion: @escaping (Bool) -> Void)
    func stop(completion: @escaping (Bool) -> Void)
}


//MARK: - Impl

final class AudioService: AudioServiceProtocol {
    
    var playerCurrentTime: TimeInterval? {
        self.audioPlayer?.currentTime
    }
    
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
    
    func startPlay(atTime time: Float? = nil, fromURL url: URL) {
        setupSettings()
        
        print(">> Will start playing audio with URL: \(url)")
        
        audioPlayer?.prepareToPlay()
        
        if let time {
            audioPlayer?.currentTime = TimeInterval(time)
            audioPlayer?.play()
        } else {
            audioPlayer?.play()
        }
    }
}


//MARK: - Public

extension AudioService {
    
    //MARK: Play
    
    func play(record: Record, onTime time: Float?, completion: @escaping (Bool) -> Void) {
        let recordURL = URLBuilder.buildURL(
            forRecordWithName: record.name,
            andFormat: record.format
        )
        
        guard
            fileManagerInstance.fileExists(atPath: recordURL.path(percentEncoded: false))
        else {
            print("ERROR: File with name \(record.name) doesn't exist!")
            completion(false)
            return
        }
        
        DispatchQueue.global().async { [unowned self] in
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                
                if let time {
                    self.startPlay(atTime: time, fromURL: recordURL)
                } else {
                    self.startPlay(fromURL: recordURL)
                }
                
                completion(true)
                
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
                completion(false)
            }
        }
    }

    
    //MARK: Pause
    
    func stop(completion: @escaping (Bool) -> Void) {
        guard self.audioPlayer != nil else {
            print("ERROR: AudioPlayer is not setted yet!")
            completion(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.stop()
            completion(true)
        }
    }
}

