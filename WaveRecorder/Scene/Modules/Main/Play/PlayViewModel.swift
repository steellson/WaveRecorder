//
//  PlayViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation


//MARK: - Protocol

protocol PlayViewModelProtocol: AnyObject {
    var progress: Float { get }
    var duration: Float { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
        
    func goBack()
    func play(atTime time: Float, completion: @escaping () -> Void)
    func stop(completion: @escaping () -> Void)
    func goForward()
    func deleteRecord()
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


//MARK: - Public

extension PlayViewModel {
    
    func goBack() {
        print("Go back tapped")
    }
    
    func play(atTime time: Float, completion: @escaping () -> Void) {
        guard !isPlaying else {
            print("ERROR: Audio is already playing!")
            return
        }
        audioService.play(record: record, onTime: time) { [unowned self] isPlaying in
            self.isPlaying = isPlaying
        }
        
        timeRefresher.register {
            self.updateTime(withValue: time)
            completion()
        }
        timeRefresher.start()
    }
    
    func stop(completion: @escaping () -> Void) {
        audioService.stop() { [unowned self] isStopped in
            self.isPlaying = !isStopped
        }
        self.resetTime()
        self.timeRefresher.stop()
        completion()
    }
    
    func goForward() {
        print("Go forward tapped")
    }
    
    func deleteRecord() {
        parentViewModel.deleteRecord()
    }
}


//MARK: - Private

private extension PlayViewModel {
    
    enum FormatType {
        case date(Date)
        case duration(TimeInterval)
    }
    
    func format(withType type: FormatType) -> String {
        switch type {
        case .date(let date): formatter.formatDate(date)
        case .duration(let duration): formatter.formatDuration(duration)
        }
    }
    
    func resetTime() {
        elapsedTime = 0
        remainingTime = duration
        updateFormattedTime()
    }
    
    func updateTime(withValue value: Float) {
        let step: Float = 0.1
        
        if elapsedTime < duration {
            elapsedTime += step
            remainingTime -= step
            
            updateFormattedTime()
        } else {
            resetTime()
        }
    }
    
    func updateFormattedTime() {
        elapsedTimeFormatted = format(withType: .duration(TimeInterval(elapsedTime)))
        remainingTimeFormatted = format(withType: .duration(TimeInterval(remainingTime)))
    }
}
