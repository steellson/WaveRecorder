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

   
    private func setupSettings(forPlayer player: AVAudioPlayer) {
        player.isMeteringEnabled = true
        player.numberOfLoops = 1
    }
}


//MARK: - Public

extension AudioService {
   
    func playAudio(withName name: String) {
        guard PathManager.instance.checkExistanceOfFile(withName: name) else {
            print("ERROR: File with name \(name) doesn't exist!")
            return
        }
        
        let audioPath = PathManager.instance.getWRRecordsDirectory().appendingPathComponent(name)
        print("** WIll start playing audio from device: \(audioPath) ...")
        
        DispatchQueue.main.async { [unowned self] in
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
                guard let audioPlayer = self.audioPlayer else { return }
                setupSettings(forPlayer: audioPlayer)
                
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    self.isPlaying = false
                } else {
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    self.isPlaying = true
                }
            } catch {
                print("ERROR: AudioPlayer could not be instantiated \(error)")
            }
        }
    }
    
    func pauseAudio() {
        DispatchQueue.main.async { [unowned self] in
            guard let audioPlayer = self.audioPlayer else { return }
            audioPlayer.pause()
        }
    }
}
