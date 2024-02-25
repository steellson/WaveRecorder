//
//  PlayToolbarViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation
import OSLog
import WRAudio
import WRResources


//MARK: - Impl

final class PlayToolbarViewModelImpl {
    
    private var record: AudioRecord
    private var isPlaying = false
    
    private var progress: Float = 0.0
    private var duration: Float = 0.0
    private var elapsedTimeString = "00:00"
    private var remainingTimeString = "00:00"
    
    private let audioPlayer: AudioPlayer
    private let helpers: HelpersStorage
    private let parentViewModel: MainViewModel

    
    //MARK: Init
    
    init(
        record: AudioRecord,
        audioPlayer: AudioPlayer,
        helpers: HelpersStorage,
        parentViewModel: MainViewModel
    ) {
        self.record = record
        self.audioPlayer = audioPlayer
        self.helpers = helpers
        self.parentViewModel = parentViewModel
        
        self.updateTime(withTimeProgress: 0)
    }
}


//MARK: - Input

extension PlayToolbarViewModelImpl: PlayToolbarViewProtocol {
    
    //MARK: Go back
    
    func goBack() throws {
        os_log("Go back tapped")
    }
    
    
    //MARK: Play
    
    func play(atTime time: Float, animation: @escaping () -> Void) throws {
        guard !isPlaying else {
            os_log("\(WRErrors.audioIsAlreadyPlaying)")
            return
        }
        
        do {
            try audioPlayer.play(record: record, onTime: time) { [weak self] progress in
                self?.updateTime(withTimeProgress: progress)
                self?.isPlaying = true
                animation()
            }
        } catch {
            os_log("\(WRErrors.cantPlayAudio) \(error)")
            return
        }
    }
    
    
    //MARK: Stop
    
    func stop() throws {
        do {
            try audioPlayer.stop()
            updateTime(withTimeProgress: 0)
            isPlaying = false
        } catch {
            os_log("\(WRErrors.cantStopAudio) \(error)")
            return
        }
    }
    
    
    //MARK: Go forward
    
    func goForward() throws {
        os_log("Go forward tapped")
    }
    
    
    //MARK: Delete
    
    func deleteRecord() throws {
        Task { try await parentViewModel.delete(record: record) }
    }
}


//MARK: - Output

extension PlayToolbarViewModelImpl: PlayToolbarViewModel {
    
    func isPlayingNow() -> Bool {
        isPlaying
    }
    
    func getProgress() -> Float {
        progress
    }
    
    func getDuration() -> Float {
        Float(record.duration ?? 0.0)
    }
    
    func getElapsedTimeString() -> String {
        elapsedTimeString
    }
    
    func getRemainingTimeString() -> String {
        remainingTimeString
    }
}


//MARK: - Private

private extension PlayToolbarViewModelImpl {

    func updateTime(withTimeProgress timeProgress: TimeInterval) {
        guard let duration = record.duration else { return }
        let remainingTime = TimeInterval(Float(duration) - progress)
        
        self.elapsedTimeString = helpers.formatter.formatDuration(timeProgress)
        self.remainingTimeString = helpers.formatter.formatDuration(remainingTime)
    }
}
