//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation


//MARK: - Protocols

protocol MainViewModelProtocol: AnyObject {    
    var records: [Record] { get set }
    
    var isRecordingNow: ((Bool) -> Void)? { get set }
    
    func getRecords()
    func importRecord(_ record: Record)
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records: [Record] = []
    
    var isRecordingNow: ((Bool) -> Void)?
    
    private let storageService: StorageServiceProtocol
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
        
//        records.forEach { storageService.delete(record: $0, completion: {_ in } )}
//        records.removeAll()
    }
}


//MARK: - Public

extension MainViewModel {
 
    func importRecord(_ record: Record) {
        storageService.save(record: record)
        records.append(record)
    }
    
    func getRecords() {
        storageService.getRecords { [weak self] result in
            switch result {
            case .success(let records):
                self?.records = records
            case .failure(let error):
                print("ERROR: Cant get records from storage! \(error)")
            }
        }
    }
}


//MARK: - Private

private extension MainViewModel {
    
}
