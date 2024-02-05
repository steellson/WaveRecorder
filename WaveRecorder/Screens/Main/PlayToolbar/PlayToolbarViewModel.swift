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
    
    func goBack()
    func play(atTime time: Float, withAnimation animation: @escaping () -> Void) async
    func stop() async
    func goForward()
    func deleteRecord() async
}


//MARK: - Impl

final class PlayToolbarViewModelImpl: PlayToolbarViewModel {
        
    var progress: Float = 0.0
    var duration: Float { Float(record.duration ?? 0) }
    
    private(set) var elapsedTimeFormatted: String = "00:00"
    private(set) var remainingTimeFormatted: String = "00:00"
    
    private var elapsedTime: Float = 0.0
    private var remainingTime: Float = 0.0
    
    private var isPlaying = false
    
    private let record: AudioRecord
    private let indexPath: IndexPath
    private let audioPlayer: AudioPlayer
    private let parentViewModel: MainViewModel
    private let timeRefresher: TimeRefresherProtocol
    private let formatter: FormatterImpl

    
    //MARK: Init
    
    init(
        record: AudioRecord,
        indexPath: IndexPath,
        audioPlayer: AudioPlayer,
        parentViewModel: MainViewModel,
        timeRefresher: TimeRefresherProtocol,
        formatter: FormatterImpl
    ) {
        self.record = record
        self.indexPath = indexPath
        self.audioPlayer = audioPlayer
        self.parentViewModel = parentViewModel
        self.timeRefresher = timeRefresher
        self.formatter = formatter
        
        resetTime()
    }
}

extension PlayToolbarViewModelImpl {
    
    //MARK: Go back
    
    func goBack() {
        os_log("Go back tapped")
    }
    
    
    //MARK: Play
    
    func play(atTime time: Float, withAnimation animation: @escaping () -> Void) async {
        guard !isPlaying else {
            os_log("\(RErrors.audioIsAlreadyPlaying)")
            return
        }
        
        do {
            try await audioPlayer.play(record: record, onTime: time)
            isPlaying = true
            
            timeRefresher.register {
                self.updateTime(withValue: time)
                animation()
            }
            
            setTimeWithDifference(startTime: time)
            timeRefresher.start()
        } catch {
            os_log("ERROR: Cant play audio! \(error)")
            return
        }
    }
    
    
    //MARK: Stop
    
    func stop() async {
        do {
            try await audioPlayer.stop()
            timeRefresher.stop()
            resetTime()
            isPlaying = false
        } catch {
            os_log("ERROR: Cant stop audio! \(error)")
            return
        }
    }
    
    
    //MARK: Go forward
    
    func goForward() {
        os_log("Go forward tapped")
    }
    
    
    //MARK: Delete
    
    func deleteRecord() async {
        await parentViewModel.delete(forIndexPath: indexPath)
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
        case .date(let date): formatter.formatDate(date)
        case .duration(let duration): formatter.formatDuration(duration)
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
        
        Task {
            if elapsedTime <= duration {
                progress += step
                elapsedTime += step
                remainingTime -= step
                updateFormattedTime()
            } else {
                await stop()
                self.resetTime()
                self.isPlaying = false
            }
        }
    }
    
    func resetTime() {
        timeRefresher.stop()
        progress = 0.0
        elapsedTime = 0.0
        remainingTime = duration
        updateFormattedTime()
    }
}
