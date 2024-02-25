//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import OSLog
import WRAudio


//MARK: - Impl

final class RecordBarViewModelImpl {
    
    private let audioRecorder: AudioRecorder = AudioRecorderImpl()
    private let parentViewModel: MainViewModel
    
    
    //MARK: Init
    
    init(
        parentViewModel: MainViewModel
    ) {
        self.parentViewModel = parentViewModel
    }
}


//MARK: - Private

private extension RecordBarViewModelImpl {
    
    func startRecord() async throws {
        try await audioRecorder.startRecord()
        try await self.parentViewModel.updateData()
        try await self.parentViewModel.shouldUpdateInterface?(true)
    }
    
    func stopRecord() async throws {
        let _ = try await audioRecorder.stopRecord()
        try await self.parentViewModel.updateData()
        try await self.parentViewModel.shouldUpdateInterface?(false)
    }
}


//MARK: Output

extension RecordBarViewModelImpl: RecordBarViewModel {

    func setupRecordAnimated(_ isRecording: Bool) async throws {
        try await isRecording ? stopRecord() : startRecord()
    }
}
