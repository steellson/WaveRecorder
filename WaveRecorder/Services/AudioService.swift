//
//  AudioService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation
import OSLog


//MARK: - Protocols

protocol AudioServiceProtocol: AnyObject, Service {
    func play(record: Record, onTime time: Float)
    func stop()
}


//MARK: - Impl

final class AudioService: AudioServiceProtocol {
    
    private let urlBuilder: URLBuilder
    private let fileManager: FileManager
    
    private var audioPlayer: AVAudioPlayer?
    
    init(
        urlBuilder: URLBuilder,
        fileManager: FileManager
    ) {
        self.urlBuilder = urlBuilder
        self.fileManager = fileManager
    }
}


//MARK: - Private

private extension AudioService {
    
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

extension AudioService {
    
    //MARK: Play
    
    func play(record: Record, onTime time: Float) {
        let recordURL = urlBuilder.buildURL(
            forRecordWithName: record.name,
            andFormat: record.format
        )
        
        guard
            fileManager.fileExists(atPath: recordURL.path(percentEncoded: false))
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
        }
    }
}

