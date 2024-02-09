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


//MARK: - Protocol

protocol PlayToolbarViewModel: AnyObject {
    var progress: Float { get }
    var duration: Float { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
    
    func goBack() throws
    func play(atTime time: Float) throws
    func stop() throws
    func goForward() throws
    func deleteRecord() throws
}


//MARK: - Impl

final class PlayToolbarViewModelImpl: PlayToolbarViewModel {
        
    var progress: Float = 0.0
    var duration: Float { Float(record.duration ?? 0.0) }
    
    private(set) var elapsedTimeFormatted: String = "00:00"
    private(set) var remainingTimeFormatted: String = "00:00"
    
    private var elapsedTime: Float = 0.0
    private var remainingTime: Float = 0.0
    
    private var isPlaying = false
    
    private var record: AudioRecord
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
        
        resetTime()
    }
}

extension PlayToolbarViewModelImpl {
    
    //MARK: Go back
    
    func goBack() throws {
        os_log("Go back tapped")
    }
    
    
    //MARK: Play
    
    func play(atTime time: Float) throws {
        guard !isPlaying else {
            os_log("\(RErrors.audioIsAlreadyPlaying)")
            return
        }
        
        do {
            try audioPlayer.play(record: record, onTime: time)
            isPlaying = true
            
            helpers.timeRefresher.register { [weak self] in
                self?.updateTime(withValue: time)
            }
            
            setTimeWithDifference(startTime: time)
            helpers.timeRefresher.start()
        } catch {
            os_log("ERROR: Cant play audio! \(error)")
            return
        }
    }
    
    
    //MARK: Stop
    
    func stop() throws {
        do {
            try audioPlayer.stop()
            helpers.timeRefresher.stop()
            resetTime()
            isPlaying = false
        } catch {
            os_log("ERROR: Cant stop audio! \(error)")
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


private extension PlayToolbarViewModelImpl {
    
    enum FormatType {
        case date(Date)
        case duration(TimeInterval)
    }
    
    //MARK: Format
    
    func format(withType type: FormatType) -> String {
        switch type {
        case .date(let date): helpers.formatter.formatDate(date)
        case .duration(let duration): helpers.formatter.formatDuration(duration)
        }
    }
    
    func updateFormattedTime() {
        elapsedTimeFormatted = format(withType: .duration(TimeInterval(elapsedTime)))
        remainingTimeFormatted = format(withType: .duration(TimeInterval(remainingTime)))
    }
    
    
    //MARK: Time
    
    func setTimeWithDifference(startTime: Float) {
        elapsedTime = startTime
        remainingTime = duration - startTime
    }
    
    func updateTime(withValue value: Float) {
        let step: Float = 0.1
        
        if elapsedTime <= duration {
            progress += step
            elapsedTime += step
            remainingTime -= step
            updateFormattedTime()
        } else {
            self.resetTime()
            self.isPlaying = false
        }
    }
    
    func resetTime() {
        helpers.timeRefresher.stop()
        progress = 0.0
        elapsedTime = 0.0
        remainingTime = duration
        updateFormattedTime()
    }
}
