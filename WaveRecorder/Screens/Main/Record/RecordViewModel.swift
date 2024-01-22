//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation


//MARK: - Protocol

protocol RecordViewModelProtocol: AnyObject {
    func record(isRecording: Bool)
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {
    
    private var record: AudioRecord?
    
    private let parentViewModel: MainViewModelProtocol
    private let audioRecorder: AudioRecorder
    
    
    //MARK: Init
    
    init(
        parentViewModel: MainViewModelProtocol,
        audioRecorder: AudioRecorder
    ) {
        self.parentViewModel = parentViewModel
        self.audioRecorder = audioRecorder
    }
}

extension RecordViewModel {
    
    //MARK: Record
    
    func record(isRecording: Bool) {
        if isRecording {
            audioRecorder.stopRecord { [unowned self] record in
                guard let record else { return }
                self.record = record
                self.parentViewModel.shouldUpdateInterface?(false)
            }
        } else {
            audioRecorder.startRecord()
            parentViewModel.shouldUpdateInterface?(true)
        }
    }
}
