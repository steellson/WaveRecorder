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
    
    func playAudio(withName name: String)
    func pauseAudio()
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
   
    func playAudio(withName name: String) {
        let audioPathURL = PathManager.instance
            .getWRRecordsDirectory()
            .appendingPathComponent(name)
            .appendingPathExtension(writedFormat)

        guard FileManager.default.fileExists(atPath: audioPathURL.path()) else {
            print("ERROR: File with name \(name) doesn't exist!")
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            do {
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioPathURL)
                guard let audioPlayer = self.audioPlayer else { return }
                setupSettings(forPlayer: audioPlayer)
                
                print(">> Will start playing audio with path: \(audioPathURL)")
        
                self.startPlay(withPlayer: audioPlayer)
                
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
            }
        }
    }
    
    func pauseAudio() {
        DispatchQueue.main.async { [unowned self] in
            self.pause()
        }
    }
}
