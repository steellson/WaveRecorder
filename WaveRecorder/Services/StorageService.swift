//
//  StorageService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 27.11.2023.
//

import Foundation
import SwiftData

//MARK: - Protocol

protocol StorageServiceProtocol: AnyObject {
    func getRecords(completion: @escaping (Result<[Record], StorageError>) -> Void)
    func get(record: Record, completion: @escaping (Result<Record, StorageError>) -> Void)
    
    func rename(record: Record, newName name: String)
    
    func save(record: Record)
    func delete(record: Record,completion: @escaping (Result<Bool, StorageError>) -> Void)
}

//MARK: Storage error

enum StorageError: Error {
    case cantGetStorageContext
    case cantGetRecordsFormStorage
    case cantGetRecordWithIDFormStorage
    case cantFetchRecordWithDescriptor
    case cantDeleteRecord
    case fetchedRecordsEmpty
}


//MARK: - Impl

final class StorageService: StorageServiceProtocol {
        
    private var container: ModelContainer?
    private var context: ModelContext?
    
    private let fileManagerInstance = FileManager.default
    
    init() {
        do {
            container = try ModelContainer(for: Record.self)
            if let container{
                context = ModelContext(container)
            }
        } catch {
            print(error)
        }
    }
}


//MARK: - Public

extension StorageService {
    
    //MARK: Get all
    
    func getRecords(completion: @escaping (Result<[Record], StorageError>) -> Void) {
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(sortBy: [SortDescriptor<Record>(\.date)])
        
        do {
            let records = try context.fetch(fetchDescriptor)
            
            if !records.isEmpty {
                completion(.success(records))
            } else {
                print("ATTENTION: Fetched records is emtpy!")
                completion(.failure(.fetchedRecordsEmpty))
            }
        } catch {
            print("ERROR: Cant get records from storage: \(error)")
            completion(.failure(.cantGetRecordsFormStorage))
        }
    }
    
    
    //MARK: Get single
    
    func get(record: Record, completion: @escaping (Result<Record, StorageError>) -> Void) {
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>()
        
        do {
            guard let record = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get fetch record with descriptor")
                completion(.failure(.cantFetchRecordWithDescriptor))
                return
            }
            completion(.success(record))
        } catch {
            print("ERROR: Cant get record with name \(record.name) from storage: \(error)")
            completion(.failure(.cantGetRecordWithIDFormStorage))
        }
    }
    
    
    //MARK: Rename
    
    func rename(record: Record, newName name: String) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>()
        
        do {
            guard 
                let oldRecord = try context.fetch(fetchDescriptor).first,
                let oldRecordDuration = oldRecord.duration
            else {
                print("ERROR: Cant get record with name \(record.name) from storage")
                return
            }
            
            context.insert(
                Record(
                    name: name,
                    date: oldRecord.date,
                    format: oldRecord.format,
                    duration: oldRecordDuration
            ))
        } catch {
            print("ERROR: Cant get old record from storage: \(error)")
            return
        }
    }
    
    
    //MARK: Save
    
    func save(record: Record) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }

        context.insert(record)
    }
    
    
    //MARK: Delete
    
    func delete(record: Record, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>()
        
        do {
            // Delete from storage
            guard let record = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record with name \(record.name) from storage")
                completion(.failure(.cantGetRecordWithIDFormStorage))
                return
            }
            context.delete(record)
            
            // Delete from file manager
            let recordURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(record.name)
                .appendingPathExtension(record.format)
            
            try fileManagerInstance.removeItem(at: recordURL)
            print("** File will deleted: \(recordURL)")
            
            completion(.success(true))
        } catch {
            print("ERROR: Cant delete record with name \(record.name), error: \(error)")
            completion(.failure(.cantDeleteRecord))
            return
        }
    }

}
