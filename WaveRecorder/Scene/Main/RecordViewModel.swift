//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation

//MARK: - Protocol

protocol RecordViewModelProtocol: AnyObject {
    var buttonRadius: CGFloat { get }
    
    func startRecord()
    func stopRecord()
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {

    private(set) var buttonRadius: CGFloat = 30.0
    
    private let recordService: RecordServiceProtocol
    
    init(
        recordService: RecordServiceProtocol
    ) {
        self.recordService = recordService
    }
}


//MARK: - Public

extension RecordViewModel {
    
    func startRecord() {
        recordService.startRecord(withName: "chizz")
    }
    
    func stopRecord() {
        recordService.stopRecord(success: true)
    }
}
