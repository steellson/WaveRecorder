//
//  PlayViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation


//MARK: - Protocol

protocol PlayViewModelProtocol: AudioServiceRepresentative {
    var progress: Float { get }
    var duration: Float { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
}


//MARK: - Impl

final class PlayViewModel: PlayViewModelProtocol {
        
    var progress: Float = 0.0
    var duration: Float { Float(record.duration ?? 0) }
    
    var elapsedTimeFormatted: String = "00:00"
    var remainingTimeFormatted: String = "00:00"
    
    private var isPlaying = false

    private var elapsedTime: Float = 0.0
    private var remainingTime: Float = 0.0
    
    private let record: Record
    private let parentViewModel: MainCellViewModelProtocol
    private let audioService: AudioServiceProtocol
    
    private let formatter = Formatter.instance
    private let timeRefresher: TimeRefresherProtocol = TimeRefresher()

    
    //MARK: Init
    
    init(
        parentViewModel: MainCellViewModelProtocol,
        audioService: AudioServiceProtocol,
        record: Record
    ) {
        self.parentViewModel = parentViewModel
        self.audioService = audioService
        self.record = record
        
        resetTime()
    }
}

extension PlayViewModel {
    
    //MARK: Go back
    
    func goBack() {
        print("Go back tapped")
    }
    
    
    //MARK: Play
    
    func play(atTime time: Float, completion: @escaping () -> Void) {
        guard !isPlaying else {
            print("ERROR: Audio is already playing!")
            return
        }
        
        audioService.play(record: record, onTime: time)
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
        audioService.stop()
        timeRefresher.stop()
        resetTime()
        isPlaying = false
        completion()
    }
    
    
    //MARK: Go forward
    
    func goForward() {
        print("Go forward tapped")
    }
    
    
    //MARK: Delete
    
    func deleteRecord() {
        parentViewModel.deleteRecord()
    }
}


private extension PlayViewModel {
    
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
            audioService.stop()
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
