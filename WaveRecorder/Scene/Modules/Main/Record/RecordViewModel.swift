//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol RecordViewModelProtocol: RecordServiceRepresentative { }


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {
    
    private var record: Record?
    
    private let parentViewModel: MainViewModelProtocol
    private let recordService: RecordServiceProtocol
    
    
    //MARK: Init
    
    init(
        parentViewModel: MainViewModelProtocol,
        recordService: RecordServiceProtocol
    ) {
        self.parentViewModel = parentViewModel
        self.recordService = recordService
    }
}

extension RecordViewModel {
    
    //MARK: Record
    
    func record(isRecording: Bool) {
        if isRecording {
            recordService.stopRecord { [unowned self] record in
                DispatchQueue.main.async {
                    guard let record else { return }
                    self.record = record
                    self.parentViewModel.shouldUpdateInterface?(false)
                    self.parentViewModel.saveRecord(record)
                }
            }
        } else {
            recordService.startRecord()
            parentViewModel.shouldUpdateInterface?(true)
        }
    }
}
