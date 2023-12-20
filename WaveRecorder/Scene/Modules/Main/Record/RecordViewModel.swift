//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol RecordViewModelProtocol: AnyObject {
    func record(isRecording: Bool)
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {
    
    private var record: Record?
    
    private let parentViewModel: MainViewModelProtocol
    private let recordService: RecordServiceProtocol
    
    init(
        parentViewModel: MainViewModelProtocol,
        recordService: RecordServiceProtocol
    ) {
        self.parentViewModel = parentViewModel
        self.recordService = recordService
    }
}


//MARK: - Public

extension RecordViewModel {
    
    func record(isRecording: Bool) {
        if isRecording {
            recordService.stopRecord { [unowned self] record in
                DispatchQueue.main.async {
                    guard let record else { return }
                    self.record = record
                    self.parentViewModel.recordStarted?(false)
                    self.parentViewModel.importRecord(record)
                }
            }
        } else {
            recordService.startRecord()
            parentViewModel.recordStarted?(true)
        }
    }
}
