//
//  AudioService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 30.11.2023.
//


import AVFoundation


//MARK: - Protocol

protocol AudioServiceProtocol: AnyObject {
    var isPlaying: Bool { get }
    
    func play(audioRecord record: Record, completion: @escaping (AudioServiceError?) -> Void)
    func pause(audioRecord record: Record, completion: @escaping (AudioServiceError?) -> Void)
}


//MARK: - Error

enum AudioServiceError: Error {
    case cantSetupAudioPlayer
    case cantPlayAudio
    case cantPauseAudio
    case audioFileWithNameDoesntExist
}


//MARK: - Impl

final class AudioService: AudioServiceProtocol {
    
    private(set) var isPlaying = false
        
    private var audioPlayer: AVAudioPlayer?
    
    private let writedFormat = "m4a"

   
    private func setupSettings(forPlayer player: AVAudioPlayer) {
        player.isMeteringEnabled = true
        player.numberOfLoops = 0
    }
    
    private func startPlay(withPlayer player: AVAudioPlayer) {
        if player.isPlaying {
            player.stop()
            self.isPlaying = false
            
            player.prepareToPlay()
            player.play()
            self.isPlaying = true
        } else {
            player.prepareToPlay()
            player.play()
            self.isPlaying = true
        }
    }
    
    private func pause() {
        guard let audioPlayer = self.audioPlayer else { return }
        audioPlayer.pause()
        self.isPlaying = false
    }
}


//MARK: - Public

extension AudioService {
   
    func play(audioRecord record: Record, completion: @escaping (AudioServiceError?) -> Void) {
        guard
            let recordPath = record.path,
            let recordSafeURL = URL(string: recordPath),
              FileManager.default.fileExists(atPath: recordPath)
        else {
            print("ERROR: File with name \(record.name) doesn't exist!")
            completion(.audioFileWithNameDoesntExist)
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: recordSafeURL)
                guard let audioPlayer = self.audioPlayer else { return }
                setupSettings(forPlayer: audioPlayer)
                
                print(">> Will start playing audio with path: \(recordSafeURL)")
        
                self.startPlay(withPlayer: audioPlayer)
                
                if isPlaying {
                    completion(nil)
                } else {
                    completion(.cantPlayAudio)
                }
                
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
                completion(.cantSetupAudioPlayer)
            }
        }
    }
    
    func pause(audioRecord record: Record, completion: @escaping (AudioServiceError?) -> Void) {
        DispatchQueue.main.async { [unowned self] in
            self.pause()
            if !isPlaying {
                completion(nil)
            } else {
                completion(.cantPauseAudio)
            }
        }
    }
}
