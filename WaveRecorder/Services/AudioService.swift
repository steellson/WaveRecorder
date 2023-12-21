//
//  AudioService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation


//MARK: - Protocol

protocol AudioServiceProtocol: AnyObject {
    func play(record: Record, onTime time: Float)
    func stop()
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
    
    func startPlay(atTime time: Float, fromURL url: URL) {
        setupSettings()
        audioPlayer?.prepareToPlay()
        audioPlayer?.currentTime = TimeInterval(time)
        audioPlayer?.play()
        
        print(">> Start playing audio with URL: \(url)")
    }
}


//MARK: - Public

extension AudioService {
    
    //MARK: Play
    
    func play(record: Record, onTime time: Float) {
        let recordURL = URLBuilder.buildURL(
            forRecordWithName: record.name,
            andFormat: record.format
        )
        
        guard
            fileManagerInstance.fileExists(atPath: recordURL.path(percentEncoded: false))
        else {
            print("ERROR: File with name \(record.name) doesn't exist!")
            return
        }
        
        DispatchQueue.global().async { [unowned self] in
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                self.startPlay(atTime: time, fromURL: recordURL)
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
            }
        }
    }

    
    //MARK: Pause
    
    func stop() {
        guard self.audioPlayer != nil else {
            print("ERROR: AudioPlayer is not setted yet!")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.stop()
        }
    }
}

