//
//  PlayToolbarViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation
import OSLog


//MARK: - Protocol

protocol PlayToolbarViewModel: AnyObject {
    var progress: Float { get }
    var duration: Float { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
    
    func goBack()
    func play(atTime time: Float, completion: @escaping () -> Void)
    func stop(completion: @escaping () -> Void)
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
    private let audioPlayer: AudioPlayer
    private let parentViewModel: RecordCellViewModel
    private let timeRefresher: TimeRefresherProtocol
    private let formatter: FormatterImpl

    
    //MARK: Init
    
    init(
        record: AudioRecord,
        audioPlayer: AudioPlayer,
        parentViewModel: RecordCellViewModel,
        timeRefresher: TimeRefresherProtocol,
        formatter: FormatterImpl
    ) {
        self.record = record
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
    
    func play(atTime time: Float, completion: @escaping () -> Void) {
        guard !isPlaying else {
            os_log("\(R.Strings.Errors.audioIsAlreadyPlaying.rawValue)")
            return
        }
        
        audioPlayer.play(record: record, onTime: time)
        isPlaying = true
    
        timeRefresher.register { [weak self] in
            self?.updateTime(withValue: time)
            completion()
        }
        
        setTimeWithDifference(startTime: time)
        timeRefresher.start()
    }
    
    
    //MARK: Stop
    
    func stop(completion: @escaping () -> Void) {
        audioPlayer.stop()
        timeRefresher.stop()
        resetTime()
        isPlaying = false
        completion()
    }
    
    
    //MARK: Go forward
    
    func goForward() {
        os_log("Go forward tapped")
    }
    
    
    //MARK: Delete
    
    func deleteRecord() async {
        await parentViewModel.deleteRecord()
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
        
        if elapsedTime <= duration {
            progress += step
            elapsedTime += step
            remainingTime -= step
            updateFormattedTime()
        } else {
            audioPlayer.stop()
            resetTime()
            isPlaying = false
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
