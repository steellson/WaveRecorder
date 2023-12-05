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
    func stopRecord(completion: ((Bool) -> Void)?)
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {

    private(set) var buttonRadius: CGFloat = 30.0
    
    private lazy var recordWillNamed: String = {
        "Record \((self.parentViewModel?.records.count ?? 0) + 1)"
    }()
    
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
    
    func stopRecord(completion: ((Bool) -> Void)?) {
        recordService.stopRecord(withName: recordWillNamed) { [weak self] record in
            guard let record else {
                print("ERROR: Record is nil")
                completion?(false)
                return
            }
            self?.parentViewModel?.saveRecord(record)
            completion?(true)
        }
    }
}
