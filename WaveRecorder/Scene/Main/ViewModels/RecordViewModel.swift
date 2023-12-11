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
    var record: Record? { get }

    func record(isRecording: Bool)
    func didRecorded()
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {
    
    var record: Record?
    
    private weak var parentViewModel: MainViewModelProtocol?
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
            recordService.stopRecord { [weak self] record in
                DispatchQueue.main.async {
                    self?.record = record
                    self?.didRecorded()
                    self?.parentViewModel?.recordStarted?(false)
                }
            }
        } else {
            recordService.startRecord()
            parentViewModel?.recordStarted?(true)
        }
    }
    
    func didRecorded() {
        guard let record else {
            print("ERROR: Cant send record to MainViewModel. Reason: Record is nil")
            return
        }
        
        if let parentVM = parentViewModel {
            parentVM.importRecord(record)
        } else {
            print("ERROR: Cant send record to MainViewModel. Reason: ParentViewModel is nil")
        }
    }
}
