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
    func stopRecord(completion: @escaping (Bool) -> Void)
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {

    private(set) var buttonRadius: CGFloat = 30.0
    
    private let recordWillNamed = "Record"
    
    private let recordService: RecordServiceProtocol
    private weak var parentViewModel: MainViewModelProtocol?
    
    init(
        recordService: RecordServiceProtocol,
        parentViewModel: MainViewModelProtocol
    ) {
        self.recordService = recordService
        self.parentViewModel = parentViewModel
    }
}


//MARK: - Public

extension RecordViewModel {
    
    func startRecord() {
        recordService.startRecord(withName: recordWillNamed)
    }
    
    func stopRecord(completion: @escaping (Bool) -> Void) {
        recordService.stopRecord(withName: recordWillNamed) { [weak self] record in
            guard let record else {
                print("ERROR: Record is nil")
                completion(false)
                return
            }
            self?.parentViewModel?.saveRecord(record)
            completion(true)
        }
    }
}
