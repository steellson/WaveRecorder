//
//  PlayViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation


//MARK: - Protocol

protocol PlayViewModelProtocol: AnyObject {
    var isPlaying: Bool { get }
    
    var progress: Float { get }
    var duration: Float { get }
    
    var elapsedTimeFormatted: String { get }
    var remainingTimeFormatted: String { get }
        
    func goBack()
    func play(atTime time: Float?)
    func stop()
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class PlayViewModel: PlayViewModelProtocol {

    var isPlaying = false
    
    var progress: Float = 0.0
    var duration: Float { Float(record.duration ?? 0) }
    
    var elapsedTimeFormatted: String {
        format(withType: .duration(0))
    }
    var remainingTimeFormatted: String {
        format(withType: .duration(record.duration ?? 0))
    }
    
    private let record: Record
    private let parentViewModel: MainCellViewModelProtocol
    private let audioService: AudioServiceProtocol

    private var timer: Timer?
    
    private let formatter = Formatter.instance

    
    init(
        parentViewModel: MainCellViewModelProtocol,
        audioService: AudioServiceProtocol,
        record: Record
    ) {
        self.parentViewModel = parentViewModel
        self.audioService = audioService
        self.record = record
    }
}


//MARK: - Public

extension PlayViewModel {
    
    func goBack() {
        print("Go back tapped")
    }
    
    func play(atTime time: Float?) {
        audioService.play(record: record, onTime: time) { [unowned self] isPlaying in
            self.isPlaying = isPlaying
        }
    }
    
    func stop() {
        if isPlaying {
            audioService.stop() { [unowned self] isStopped in
                self.isPlaying = !isStopped
            }
        }
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
}
