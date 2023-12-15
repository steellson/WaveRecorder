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
    
    var recordStarted: ((Bool) -> Void)? { get set }
    var dataSourceUpdated: (() -> Void)? { get set }
    
    func importRecord(_ record: Record)
    
    func getRecords()
    func search(withText text: String)
    
    func rename(record: Record, newName name: String, completion: @escaping (Bool) -> Void)
    func delete(record: Record, completion: @escaping (Bool) -> Void)
    
    func makeViewModelForCell(atIndex index: Int) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records: [Record] = []
    
    var recordStarted: ((Bool) -> Void)?
    var dataSourceUpdated: (() -> Void)?
    
    private let storageService: StorageServiceProtocol
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
    }
    
    func makeViewModelForCell(atIndex index: Int) -> MainCellViewModelProtocol {
        AssemblyBuilder.getMainCellViewModel(withRecord: records[index])
    }
}


//MARK: - Public

extension MainViewModel {
    
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
    
    func importRecord(_ record: Record) {
        storageService.save(record: record)
        records.append(record)
        dataSourceUpdated?()
    }
    
    func rename(record: Record, newName name: String, completion: @escaping (Bool) -> Void) {
        storageService.rename(record: record, newName: name) { [weak self] isRenamed in
            switch isRenamed {
            case .success(let isRenamed):
                if isRenamed {
                    self?.dataSourceUpdated?()
                    completion(true)
                }
            case .failure(let error):
                completion(false)
                print("ERROR: Cant rename record! \(error)")
            }
        }
    }
    
    func delete(record: Record, completion: @escaping (Bool) -> Void) {
        storageService.delete(record: record) { [weak self] result in
            switch result {
            case .success:
                guard
                    let recordIndex = self?.records.firstIndex(where: { $0.name == record.name })
                else {
                    print("ERROR: Cant delete record with name \(record.name) from array")
                    completion(false)
                    return
                }
                
                self?.records.remove(at: recordIndex)
                self?.dataSourceUpdated?()
                completion(true)
                print("ERROR: Record with name \(record.name) deleted!")
                
            case .failure(let error):
                completion(false)
                print("ERROR: Cant delete record with name \(record.name). \(error)")
            }
        }
    }
    
    func search(withText text: String) {
        guard !text.isEmpty else { return }
        
        storageService.searchRecords(withText: text) { [weak self] result in
            switch result {
            case .success(let records):
                print(records)
                self?.records = records
                self?.dataSourceUpdated?()
            case .failure(let error):
                self?.dataSourceUpdated?()
                print("ERROR: Cant search records with text \(text). \(error)")
            }
        }
    }
}
