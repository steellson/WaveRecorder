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
    
    func set(newName name: String, toRecord record: Record)
    func save(record: Record)
    func delete(record: Record, completion: @escaping (Result<Bool, StorageError>) -> Void)
    
    func searchRecord(withText
                     text: String,
                     completion: @escaping (Result<[Record], StorageError>) -> Void)

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
            print("ERROR: Cant get record with id \(record.id) from storage: \(error)")
            completion(.failure(.cantGetRecordWithIDFormStorage))
        }
    }
    
    
     //MARK: Search
     
     func searchRecord(withText text: String, completion: @escaping (Result<[Record], StorageError>) -> Void) {
         //
     }
    
    
    //MARK: Save
    
    func save(record: Record) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }

        context.insert(record)
    }
    
    
    //MARK: Rename
    
    func set(newName name: String, toRecord record: Record) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>()
        
        do {
            guard let oldRecord = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record widh id \(record.id) from storage")
                return
            }
            
            context.insert(
                Record(
                    name: name,
                    date: oldRecord.date,
                    duration: oldRecord.duration,
                    path: oldRecord.path
            ))
        } catch {
            print("ERROR: Cant get old record from storage: \(error)")
            return
        }
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
                print("ERROR: Cant get record widh id \(record.id) from storage")
                completion(.failure(.cantGetRecordWithIDFormStorage))
                return
            }
            context.delete(record)
            
            // Delete from file manager
            let storedRecordURL = PathManager.instance.getPathOfRecord(witnName: record.name).appendingPathExtension("m4a")
            print("** File will deleted: \(storedRecordURL)")
            try FileManager.default.removeItem(at: storedRecordURL)
            completion(.success(true))
            
        } catch {
            print("ERROR: Cant delete record with id \(record.id), error: \(error)")
            completion(.failure(.cantDeleteRecord))
            return
        }
    }

}
