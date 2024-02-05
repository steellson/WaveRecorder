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
    func record(isRecording: Bool) async
}


//MARK: - Impl

final class RecordBarViewModelImpl: RecordViewModel {
    
    private var record: AudioRecord?
    
    private let parentViewModel: MainViewModel
    private let audioRecorder: AudioRecorder
    
    
    //MARK: Init
    
    init(
        parentViewModel: MainViewModel,
        audioRecorder: AudioRecorder
    ) {
        self.parentViewModel = parentViewModel
        self.audioRecorder = audioRecorder
    }
}


//MARK: - Private

private extension RecordBarViewModelImpl {
    
    func startRecord() async {
        guard let recorded = try? await audioRecorder.stopRecord() else {
            os_log("ERROR: Cant stop recording")
            return
        }
        
        self.record = recorded
        await self.parentViewModel.resetData()
        await self.parentViewModel.shouldUpdateInterface?(false)
    }
    
    
    func stopRecord() async {
        guard let _ = try? await audioRecorder.startRecord() else {
            os_log("ERROR: Cant start recording")
            return
        }
        
        await self.parentViewModel.resetData()
        await self.parentViewModel.shouldUpdateInterface?(true)
    }
}


//MARK: Public

extension RecordBarViewModelImpl {
    
    func record(isRecording: Bool) async {
        !isRecording
        ? await stopRecord()
        : await startRecord()
    }
}
