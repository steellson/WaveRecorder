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
    func play(record: AudioRecord, onTime time: Float) async throws
    func stop() async throws
}


//MARK: - Errors

enum AudioPlayerError: Error {
    case audioPlayerIsNotSettedYet
    case audioPlayerCantBeInstantiated
    case audioCantStartPlaying
    case audioIsNotPlayinngNow
    case cantSetupAudioPlayer
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
    
    func setupSettings() throws {
        guard let audioPlayer = self.audioPlayer else {
            os_log("ERROR: AudioPlayer is not setted yet!")
            throw AudioPlayerError.audioPlayerIsNotSettedYet
        }
        
        audioPlayer.isMeteringEnabled = true
        audioPlayer.numberOfLoops = 0
    }
    
    func startPlay(atTime time: Float, fromURL url: URL) throws {
        do {
            try setupSettings()
            
            guard let audioPlayer else {
                os_log("ERROR: AudioPlayer cannot be setted!")
                throw AudioPlayerError.cantSetupAudioPlayer
            }
            
            audioPlayer.prepareToPlay()
            audioPlayer.currentTime = TimeInterval(time)
            audioPlayer.play()
            
        } catch {
            os_log("ERROR: Cant set settings to audio player!")
            throw AudioPlayerError.cantSetupAudioPlayer
        }
    }
}


//MARK: - Public

extension AudioPlayerImpl {
    
    //MARK: Play
    
    func play(record: AudioRecord, onTime time: Float) async throws {
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
        
        Task {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                self.audioPlayer = audioPlayer
                
                try startPlay(atTime: time, fromURL: recordURL)
                
                guard audioPlayer.isPlaying else {
                    os_log(">> Cant start playing audio with URL: \(recordURL)")
                    throw AudioPlayerError.audioCantStartPlaying
                }
                os_log(">> Start playing audio with URL: \(recordURL)")
                
            } catch {
                os_log("ERROR: AudioPlayer could not be instantiated! \(error)")
                throw AudioPlayerError.audioPlayerCantBeInstantiated
            }
    
        }
    }

    
    //MARK: Pause
    
    func stop() async throws {
        Task {
            if let player = self.audioPlayer, player.isPlaying {
                self.audioPlayer?.stop()
                os_log("SUCCESS: Audio stopped!")
                self.audioPlayer = nil
            } else {
                os_log("ERROR: Audio is not stopped because its not playing now!")
                throw AudioPlayerError.audioIsNotPlayinngNow
            }
        }
    }
}

