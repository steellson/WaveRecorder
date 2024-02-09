//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import OSLog
import WRAudio


//MARK: - Protocol

protocol RecordViewModel: AnyObject {
    func record(isRecording: Bool) async throws
}


//MARK: - Impl

final class RecordBarViewModelImpl: RecordViewModel {
        
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


//MARK: Public

extension RecordBarViewModelImpl {
    
    func record(isRecording: Bool) async throws {
        isRecording
        ? try await stopRecord()
        : try await startRecord()
    }
}
