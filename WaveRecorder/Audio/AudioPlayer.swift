//
//  AudioPlayer.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation
import OSLog


//MARK: - Protocols

protocol AudioPlayer: AnyObject {
    func play(record: AudioRecord, onTime time: Float)
    func stop()
}


//MARK: - Impl

final class AudioPlayerImpl: AudioPlayer {
    
    private let audioPathManager: AudioPathManager
    
    private var audioPlayer: AVAudioPlayer?
    
    
    init() {
        self.audioPathManager = AudioPathManagerImpl()
    }
}


//MARK: - Private

private extension AudioPlayerImpl {
    
    func setupSettings() {
        guard let audioPlayer = self.audioPlayer else {
            os_log("ERROR: AudioPlayer is not setted yet!")
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
        
        os_log(">> Start playing audio with URL: \(url)")
    }
}


//MARK: - Public

extension AudioPlayerImpl {
    
    //MARK: Play
    
    func play(record: AudioRecord, onTime time: Float) {
        let recordURL = audioPathManager.createURL(
            forRecordWithName: record.name,
            andFormat: record.format.rawValue
        ).deletingPathExtension()
        
        guard
            audioPathManager.isFileExist(recordURL)
        else {
            os_log("ERROR: File with name \(record.name) doesn't exist!")
            return
        }
        
        DispatchQueue.global().async { [unowned self] in
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                self.startPlay(atTime: time, fromURL: recordURL)
            } catch {
                os_log("ERROR: AudioPlayer could not be instantiated \(error)")
            }
        }
    }

    
    //MARK: Pause
    
    func stop() {
        guard self.audioPlayer != nil else {
            os_log("ERROR: AudioPlayer is not setted yet!")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
    }
}

