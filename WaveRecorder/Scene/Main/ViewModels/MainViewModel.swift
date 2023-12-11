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
    
    func getRecords()
    func importRecord(_ record: Record)
    func renameRecord(_ record: Record, newName name: String)
    func delete(record: Record)
    func search(withText text: String)
    
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
    
    func renameRecord(_ record: Record, newName name: String) {
        storageService.rename(record: record, newName: name)
        getRecords()
        dataSourceUpdated?()
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
                self?.dataSourceUpdated?()
                print("ERROR: Record with name \(record.name) deleted!")
                
            case .failure(let error):
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
    
    func makeViewModelForCell(atIndex index: Int) -> MainCellViewModelProtocol {
        AssemblyBuilder.buildMainCellViewModel(withRecord: records[index])
    }
}
