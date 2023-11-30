//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation

//MARK: - Protocols

protocol MainViewModelProtocol: AnyObject {
    var childViewModels: [AnyObject]? { get set }
    
    var records: [Record] { get set }
    
    func getRecords()
    func getRecord(withID id: String, completion: @escaping (Result<Record, Error>) -> Void)
    func deleteRecord(withID id: String, completion: ((Result<Bool, Error>) -> Void)?)
    func saveRecord(_ record: Record)
    func searchRecord(withText text: String)
    
    func playDidTapped(onRecord record: Record)
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records: [Record] = []

    var childViewModels: [AnyObject]?
    
    private let storageService: StorageServiceProtocol
    
    
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
  
        getRecords()
    }
    
}


//MARK: - Public

extension MainViewModel {
    
    func playDidTapped(onRecord record: Record) {
        childViewModels.map {
            let a = $0 as? any PlayToolbarViewModelProtocol
            a?.record = record
        }
    }
    
    //MARK: Get all
    func getRecords() {
        records = []
        storageService.getRecords() { [weak self] result in
            switch result {
            case .success(let records):
                self?.records = records
            case .failure(let error):
                print("ERROR: \(error)")
                self?.records = []
            }
        }
    }
    
    
    //MARK: Get single
    func getRecord(withID id: String, completion: @escaping (Result<Record, Error>) -> Void) {
        storageService.getRecord(withID: id) { result in
            switch result {
            case .success(let record):
                completion(.success(record))
            case .failure(let error):
                print("ERROR: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    //MARK: Delete
    func deleteRecord(withID id: String, completion: ((Result<Bool, Error>) -> Void)?) {
        storageService.deleteRecord(withID: id) { result in
            switch result {
            case .success(let deleted):
                print("SUCCESS: Record with id \(id) deleted!")
                completion?(.success(deleted))
            case .failure(let error):
                print("ERROR: \(error)")
                completion?(.failure(error))
            }
        }
    }
    
    
    //MARK: Search
    func searchRecord(withText text: String) {
        
    }
    
    
    //MARK: Save
    func saveRecord(_ record: Record) {
        storageService.save(record: record)
        getRecords()
    }
}
