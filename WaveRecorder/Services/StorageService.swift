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
    
    func getRecord(withID
                   id: String,
                   completion: @escaping (Result<Record, StorageError>) -> Void)
    
    func searchRecord(withText
                     text: String,
                     completion: @escaping (Result<[Record], StorageError>) -> Void)

    
    func deleteRecord(withID 
                      id: String,
                      completion: @escaping (Result<Bool, StorageError>) -> Void)
    
    func save(record: Record)
    func renameRecord(withID id: String, newName name: String)
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
    
    func getRecord(withID
                   id: String,
                   completion: @escaping (Result<Record, StorageError>) -> Void) {
        
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id == id })
        
        do {
            guard let record = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get fetch record with descriptor")
                completion(.failure(.cantFetchRecordWithDescriptor))
                return
            }
            completion(.success(record))
        } catch {
            print("ERROR: Cant get record with id \(id) from storage: \(error)")
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
    
    func renameRecord(withID id: String, newName name: String) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id == id })
        
        do {
            guard let oldRecord = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record widh id \(id) from storage")
                return
            }
            
            context.insert(
                Record(
                    name: name,
                    path: oldRecord.path,
                    duration: oldRecord.duration,
                    date: oldRecord.date
            ))
        } catch {
            print("ERROR: Cant get old record from storage: \(error)")
            return
        }
    }
    
    
    //MARK: Delete
    
    func deleteRecord(withID id: String, completion: @escaping (Result<Bool, StorageError>) -> Void) {
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id == id })
        
        do {
            guard let record = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record widh id \(id) from storage")
                completion(.failure(.cantGetRecordWithIDFormStorage))
                return
            }
            context.delete(record)
            completion(.success(true))
        } catch {
            print("ERROR: Cant delete record with id \(id), error: \(error)")
            completion(.failure(.cantDeleteRecord))
            return
        }
    }

}
