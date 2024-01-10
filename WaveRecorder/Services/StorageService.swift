//
//  StorageService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 27.11.2023.
//

import Foundation
import OSLog
import SwiftData

//MARK: - Protocols

protocol StorageServiceProtocol: AnyObject, Service {
    func save(record: Record, completion: @escaping (Result<Void, StorageError>) -> Void)
    func getRecords(completion: @escaping (Result<[Record], StorageError>) -> Void)
    func delete(record: Record, completion: @escaping (Result<Void, StorageError>) -> Void)
    func searchRecords(withText text: String, completion: @escaping (Result<[Record], StorageError>) -> Void)
    func rename(record: Record, newName name: String, completion: @escaping (Result<Void, StorageError>) -> Void)
}

protocol StorageServiceRepresentative: AnyObject {
    var numberOfRecords: Int { get }
    
    func uploadRecords()
    func saveRecord(_ record: Record)
    func getRecord(forIndexPath indexPath: IndexPath) -> Record
    func rename(recordForIndexPath indexPath: IndexPath, newName name: String)
    func search(withText text: String)
    func delete(recordForIndexPath indexPath: IndexPath)
}


//MARK: Storage error

enum StorageError: Error {
    case cantGetStorageContext
    case cantGetRecordsFormStorage
    case cantGetRecordWithIDFormStorage
    case cantFetchRecordWithDescriptor
    case cantRenameRecord
    case cantDeleteRecord
    case fetchedRecordsEmpty
}


//MARK: - Impl

final class StorageService: StorageServiceProtocol {
        
    private var container: ModelContainer?
    private var context: ModelContext?
    
    private let fileManager: FileManager
    
    init(
        fileManager: FileManager
    ) {
        self.fileManager = fileManager
        initialSetup()
    }
    
    private func initialSetup() {
        do {
            container = try ModelContainer(for: Record.self)
            
            if let container{
                context = ModelContext(container)
            }
        } catch {
            os_log("\(error)")
        }
    }
}

extension StorageService {
    
    //MARK: Save
    
    func save(record: Record, completion: @escaping (Result<Void, StorageError>) -> Void) {
        guard let context else {
            os_log("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }

        context.insert(record)
        completion(.success(()))
    }
    
    
    //MARK: Get all
    
    func getRecords(completion: @escaping (Result<[Record], StorageError>) -> Void) {
        guard let context else {
            os_log("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(sortBy: [SortDescriptor<Record>(\.date, order: .reverse)])
        
        do {
            let records = try context.fetch(fetchDescriptor)
            
            if !records.isEmpty {
                completion(.success(records))
            } else {
                os_log("ATTENTION: Fetched records is emtpy!")
                completion(.failure(.fetchedRecordsEmpty))
            }
        } catch {
            os_log("ERROR: Cant get records from storage: \(error)")
            completion(.failure(.cantGetRecordsFormStorage))
        }
    }
    
    
    //MARK: Delete
    
    func delete(record: Record, completion: @escaping (Result<Void, StorageError>) -> Void) {
        guard let context else {
            os_log("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let originalName = record.name
        let predicate = #Predicate<Record> { $0.name == originalName }
        let fetchDescriptor = FetchDescriptor<Record>(predicate: predicate)
        
        do {
            // Delete from storage
            guard let record = try context.fetch(fetchDescriptor).first else {
                os_log("ERROR: Cant get record with name \(originalName) from storage")
                completion(.failure(.cantGetRecordWithIDFormStorage))
                return
            }
            context.delete(record)
            
            // Delete from file manager
            let recordURL = URLBuilder.buildURL(
                forRecordWithName: record.name,
                andFormat: record.format
            )
            try fileManager.removeItem(at: recordURL)
            os_log("** File will deleted: \(recordURL)")
            
            completion(.success(()))
        } catch {
            os_log("ERROR: Cant delete record with name \(record.name), error: \(error)")
            completion(.failure(.cantDeleteRecord))
            return
        }
    }

 
    //MARK: Search
    
    func searchRecords(withText text: String, completion: @escaping (Result<[Record], StorageError>) -> Void) {
        guard let context else {
            os_log("ERROR: Cant get storage context")
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
                os_log("ATTENTION: Fetched records is emtpy!")
                completion(.success(records))
            }
        } catch {
            os_log("ERROR: Cant get records from storage: \(error)")
            completion(.failure(.cantGetRecordsFormStorage))
        }
    }
    
    
    //MARK: Rename
    
    func rename(record: Record, newName name: String, completion: @escaping (Result<Void, StorageError>) -> Void) {
        guard let context else {
            os_log("ERROR: Cant get storage context")
            completion(.failure(.cantGetStorageContext))
            return
        }
        
        let originalName = record.name
        let predicate = #Predicate<Record> { $0.name == originalName }
        let fetchDescriptor = FetchDescriptor<Record>(predicate: predicate)
        
        do {
            guard 
                let record = try context.fetch(fetchDescriptor).first,
                let recordDuration = record.duration
            else {
                os_log("ERROR: Cant get record with name \(record.name) from storage")
                completion(.failure(.cantGetRecordWithIDFormStorage))
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
                    date: record.date,
                    format: record.format,
                    duration: recordDuration
            ))
            
            completion(.success(()))
            os_log("** File \(originalName) renamed on: \(name)")
        } catch {
            os_log("ERROR: Cant get old record from storage: \(error)")
            completion(.failure(.cantRenameRecord))
            return
        }
    }
}
