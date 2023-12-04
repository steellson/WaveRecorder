//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation

//MARK: - Protocols

protocol MainViewModelProtocol: AnyObject {    
    var records: Observable<[Record]> { get }
    var isRecordingNow: Observable<Bool> { get }
 
    func didStartRecording()
    func didFinishRecording(ofRecord record: Record)
    func didDeleted(record: Record)
        
    func setupChildViewModel(withIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var records = Observable<[Record]>(value: [])
    
    var isRecordingNow = Observable(value: false)
    
    private let storageService: StorageServiceProtocol
    
    
    init(
        storageService: StorageServiceProtocol
    ) {
        self.storageService = storageService
  
        getRecords()
    }
    
}

//MARK: - Private

private extension MainViewModel {
    
    //MARK: Get all
    func getRecords() {
        records.value = []
        storageService.getRecords() { [weak self] result in
            switch result {
            case .success(let records):
                self?.records.value = records
            case .failure(let error):
                print("ERROR: \(error)")
                self?.records.value = []
            }
        }
    }
    
    
    //MARK: Get single
    func get(record: Record, completion: @escaping (Result<Record, Error>) -> Void) {
        storageService.get(record: record) { result in
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
    func delete(record: Record, completion: ((Result<Bool, Error>) -> Void)?) {
        storageService.delete(record: record) { result in
            switch result {
            case .success(let deleted):
                print("SUCCESS: Record with id \(record.id) deleted!")
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
}


//MARK: - Public

extension MainViewModel {
    
    //MARK: Did start rec
    func didStartRecording() {
        #warning("RECORDING: checkpoint here")
        // need send signal to view for redrawing
        isRecordingNow.value = true
    }
    
    
    //MARK: Did finish rec
    func didFinishRecording(ofRecord record: Record) {
        // need send signal to view for redrawing
        isRecordingNow.value = false
        storageService.save(record: record) 
        records.value.append(record)
    }
    
    
    //MARK: Did delete rec
    func didDeleted(record: Record) {
        storageService.delete(record: record) { [weak self] result in
            switch result {
            case .success: break
//                self?.records.value.enumerated().forEach({ index, value in
//                    if value.id == record.id {
//                        self?.records.value.remove(at: index)
//                    }
//                })
            case .failure(let error):
                print("ERROR: Cant delete record with name: \(record.name). \(error)")
            }
        }
    }

    
    //MARK: Seutp child VM
    func setupChildViewModel(withIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol {
        Assembly.builder.buildMainCellViewModel(withRecord: records.value[indexPath.row])
    }
}
