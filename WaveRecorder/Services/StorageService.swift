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
    func delete(record: Record,completion: @escaping (Result<Bool, StorageError>) -> Void)
    func searchRecords(withText text: String, completion: @escaping (Result<[Record], StorageError>) -> Void)
    
    func save(record: Record)
    func rename(record: Record, newName name: String)
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
            let recordURL = URLBuilder.buildURL(
                forRecordWithName: record.name,
                andFormat: record.format
            )
            try fileManagerInstance.removeItem(at: recordURL)
            print("** File will deleted: \(recordURL)")
            
            completion(.success(true))
        } catch {
            print("ERROR: Cant delete record with name \(record.name), error: \(error)")
            completion(.failure(.cantDeleteRecord))
            return
        }
    }

 
    //MARK: Search
    
    func searchRecords(withText text: String, completion: @escaping (Result<[Record], StorageError>) -> Void) {
        guard let context else {
            print("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let predicate = #Predicate<Record> { $0.name.contains(text) }
        let fetchDescriptor = FetchDescriptor<Record>(predicate: predicate)

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
    
    
    //MARK: Save
    
    func save(record: Record) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }

        context.insert(record)
    }
    
    
    //MARK: Rename
    
    func rename(record: Record, newName name: String) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>()
        
        do {
            let records = try context.fetch(fetchDescriptor)
            
            guard
                let oldRecord = records.first(where: { $0.id == record.id }),
                let oldRecordDuration = oldRecord.duration,
                records.filter({ $0.name == name }).isEmpty
            else {
                print("ERROR: Cant get record with name \(record.name) from storage")
                return
            }
            
            // Change file name on device and replace it in storage
            let originPath = URLBuilder.buildURL(forRecordWithName: record.name, andFormat: record.format)
            let destinationPath = URLBuilder.buildURL(forRecordWithName: name, andFormat: record.format)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            
            context.delete(record)
            context.insert(
                Record(
                    name: name,
                    date: oldRecord.date,
                    format: oldRecord.format,
                    duration: oldRecordDuration
            ))
            
            print("** File \(record.name) renamed on: \(name)")
        } catch {
            print("ERROR: Cant get old record from storage: \(error)")
            return
        }
    }
}
