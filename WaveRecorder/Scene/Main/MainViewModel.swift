//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation

//MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    var records: [Record] { get }
    
    func getRecords()
    func getRecord(withID id: String, completion: @escaping (Result<Record, Error>) -> Void)
    func deleteRecord(withID id: String, completion: ((Result<Bool, Error>) -> Void)?)
    func saveRecord(_ record: Record)
    func searchRecord(withText text: String)
}

//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    private(set) var records: [Record] = []

    private let storageService: StorageServiceProtocol
    
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
  
    }
}


//MARK: - Public

extension MainViewModel {
    
    //MARK: Get all
    func getRecords() {
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
    }
}
