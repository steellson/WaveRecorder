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

//MARK: - Private

private extension RecordViewModel {
     
    func createNewRecord() -> Record {
        Record(
            name: recordWillNamed,
            date: .now,
            duration: nil,
            path: nil
        )
    }
}


//MARK: - Public

extension RecordViewModel {

    func startRecord() {
        let newRecord = createNewRecord()
        
        recordService.startRecording(record: newRecord) { [weak self] result in
            switch result {
            case .success(let record):
                self?.parentViewModel?.didStartRecording(ofRecord: record)
            case .failure(let error):
                print("Alert with errpr \(error) presented")
            }
        }
    }
    
    func stopRecord(completion: ((Bool) -> Void)?) {
        recordService.stopRecording { [weak self] result in
            switch result {
            case .success(let record):
                self?.parentViewModel?.didFinishRecording(ofRecord: record)
            case .failure(let error):
                print("Alert with errpr \(error) presented")
            }
        }
    }
}
