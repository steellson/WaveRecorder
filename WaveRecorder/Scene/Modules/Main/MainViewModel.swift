//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation


//MARK: - Protocols

protocol InterfaceUpdatable: AnyObject {
    var shouldUpdateInterface: ((Bool) -> Void)? { get set }
}

protocol MainViewModelProtocol: InterfaceUpdatable, StorageServiceRepresentative {
    var numberOfRecords: Int { get }
        
    func importRecord(_ record: Record)
    
    func makeRecordView() -> PresentationUpdatable
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var shouldUpdateInterface: ((Bool) -> Void)?
    
    var numberOfRecords: Int {
        records.count
    }
        
    private var records: [Record] = []
    private let storageService: StorageServiceProtocol
    
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
        
        uploadRecords()
    }
    
    
    func makeRecordView() -> PresentationUpdatable {
        AssemblyBuilder.get(subModule: .record(parentVM: self))
    }
    
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol {
        AssemblyBuilder.getMainCellViewModel(
            withRecord: records[indexPath.item],
            indexPath: indexPath
        )
    }
}


//MARK: - Public

extension MainViewModel {
    
    func uploadRecords() {
        storageService.getRecords { [unowned self] result in
            switch result {
            case .success(let records):
                self.records = records
                self.shouldUpdateInterface?(false)
            case .failure(let error):
                print("ERROR: Cant get records from storage! \(error)")
            }
        }
    }
    
    func importRecord(_ record: Record) {
        storageService.save(record: record) { [unowned self] _ in
            self.records.append(record)
        }
    }
    
    func getRecord(forIndexPath indexPath: IndexPath) -> Record {
        records[indexPath.item]
    }
    
    func rename(recordForIndexPath indexPath: IndexPath, newName name: String) {
        storageService.rename(
            record: records[indexPath.item],
            newName: name
        ) { [unowned self] isRenamed in
            
            switch isRenamed {
            case .success:
                self.records[indexPath.item].name = name
            case .failure(let error):
                print("ERROR: Cant rename record! \(error)")
            }
        }
    }
    
    func search(withText text: String) {
        guard !text.isEmpty else {
            uploadRecords()
            return
        }
        
        storageService.searchRecords(withText: text) { [unowned self] result in
            switch result {
            case .success(let records):
                self.records = records
                self.shouldUpdateInterface?(false)
            case .failure(let error):
                print("ERROR: Cant search records with text \(text). \(error)")
            }
        }
    }
    
    func delete(recordForIndexPath indexPath: IndexPath) {
        let record = records[indexPath.item]
        
        storageService.delete(record: record) { [unowned self] result in
            switch result {
            case .success:
                self.records.remove(at: indexPath.item)
                self.shouldUpdateInterface?(false)
                print("SUCCESS: Record with name \(record.name) deleted!")
                
            case .failure(let error):
                print("ERROR: Cant delete record with name \(record.name). \(error)")
            }
        }
    }
}

//MARK: - Private

private extension MainViewModel {
    

}
