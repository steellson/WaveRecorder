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
    func play(atTime time: Float?, completion: @escaping (TimeInterval) -> Void)
    func stop(completion: @escaping () -> Void)
    func goForward()
    func deleteRecord()
}


//MARK: - Impl

final class PlayViewModel: PlayViewModelProtocol {
    
    var progress: Float = 0.0
    var duration: Float { Float(record.duration ?? 0) }
    
    var elapsedTimeFormatted: String {
        format(withType: .duration(0))
    }
    var remainingTimeFormatted: String {
        format(withType: .duration(record.duration ?? 0))
    }
    
    private var isPlaying = false
    
    private let record: Record
    private let parentViewModel: MainCellViewModelProtocol
    private let audioService: AudioServiceProtocol
    
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
    
    func play(atTime time: Float?, completion: @escaping (TimeInterval) -> Void) {
        guard !isPlaying else {
            print("ERROR: Audio is already playing!")
            return
        }
        audioService.play(record: record, onTime: time) { [unowned self] isPlaying in
            self.isPlaying = isPlaying
            completion(0.1)
        }
    }
    
    func stop(completion: @escaping () -> Void) {
        audioService.stop() { [unowned self] isStopped in
            self.isPlaying = !isStopped
            completion()
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
