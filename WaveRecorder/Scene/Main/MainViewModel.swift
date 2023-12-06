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
    var recordDidFinished: (() -> Void)? { get set }
    
    func getRecords()
    func importRecord(_ record: Record)
    func delete(record: Record)
    
    func makeViewModelForCell(atIndex index: Int) -> MainCellViewModel
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records: [Record] = [] {
        didSet {
            records.forEach { print($0.url) }
        }
    }
    
    var isRecordingNow: ((Bool) -> Void)?
    var recordDidFinished: (() -> Void)?
    
    private let storageService: StorageServiceProtocol
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
        
    }
}


//MARK: - Public

extension MainViewModel {
 
    func importRecord(_ record: Record) {
        storageService.save(record: record)
        records.append(record)
        recordDidFinished?()
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
    
    func delete(record: Record) {
        storageService.delete(record: record) { [weak self] result in
            switch result {
            case .success:
                guard
                    let recordIndex = self?.records.firstIndex(where: { $0.name == record.name })
                else {
                    print("ERROR: Cant delete record with name \(record.name) from array")
                    return
                }
                
                self?.records.remove(at: recordIndex)
                print("ERROR: Record with name \(record.name) deleted!")
                
            case .failure(let error):
                print("ERROR: Cant delete record with name \(record.name). \(error)")
            }
        }
    }
    
    func makeViewModelForCell(atIndex index: Int) -> MainCellViewModel {
        let viewModel = MainCellViewModel(parentViewModel: self)
        viewModel.record = records[index]
        return viewModel
    }
}


//MARK: - Private

private extension MainViewModel {
    
}
