//
//  RedactorViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 09.02.2024.
//

import Foundation
import OSLog
import WRAudio


typealias AudioRecordMetadata = (name: String, duration: String, date: String)


//MARK: - Protocol

protocol RedactorViewModel: AnyObject {
    var audioRecordMetadata: AudioRecordMetadata { get }
}


//MARK: - Impl

final class RedactorViewModelImpl: RedactorViewModel {
    
    private(set) var audioRecordMetadata = AudioRecordMetadata(name: "", duration: "", date: "")
    
    private let audioRecord: AudioRecord
    private let helpers: HelpersStorage
    
    
    //MARK: Init
    
    init(
        audioRecord: AudioRecord,
        helpers: HelpersStorage
    ) {
        self.audioRecord = audioRecord
        self.helpers = helpers
        
        loadRecordMetadata()
    }
}

//MARK: - Private

private extension RedactorViewModelImpl {
    
    func loadRecordMetadata() {
        self.audioRecordMetadata = AudioRecordMetadata(
            name: helpers.formatter.formatName(audioRecord.name),
            duration: helpers.formatter.formatDuration(audioRecord.duration ?? 0.0),
            date: helpers.formatter.formatDate(audioRecord.date)
        )
    }
}
