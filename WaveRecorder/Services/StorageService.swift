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
    func getRecords() -> [Record]
    func getRecord(withID id: String) -> Record?
    
    func save(record: Record)
    func renameRecord(withID id: String, newName name: String)
    func deleteRecord(withID id: String)
}


//MARK: - Impl

final class StorageService: StorageServiceProtocol {
    
    //MARK: Config
    
    private let configuration = ModelConfiguration(for: Record.self, isStoredInMemoryOnly: true)
    
    private lazy var container: ModelContainer? = {
        try? ModelContainer(for: Record.self, configurations: configuration)
    }()
    
    private lazy var context: ModelContext? =  {
        guard let container else { return nil }
        return ModelContext(container)
    }()
}


//MARK: - Public

extension StorageService {
    
    //MARK: Get all
    
    func getRecords() -> [Record] {
        guard let context else {
            print("ERROR: Cant get storage context")
            return []
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.date > $0.date })
        
        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            print("ERROR: Cant get records from storage: \(error)")
            return []
        }
    }
    
    
    //MARK: Get single
    
    func getRecord(withID id: String) -> Record? {
        guard let context else {
            print("ERROR: Cant get storage context")
            return nil
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id.uuidString == id })
        
        do {
            return try context.fetch(fetchDescriptor).first
        } catch {
            print("ERROR: Cant get records from storage: \(error)")
            return nil
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
    
    func renameRecord(withID id: String, newName name: String) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id.uuidString == id })
        
        do {
            guard let oldRecord = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record widh id \(id) from storage")
                return
            }
            
            context.insert(
                Record(
                    id: oldRecord.id,
                    name: name,
                    duration: oldRecord.duration,
                    date: oldRecord.date
            ))
        } catch {
            print("ERROR: Cant get old record from storage: \(error)")
            return
        }
    }
    
    
    //MARK: Delete
    
    func deleteRecord(withID id: String) {
        guard let context else {
            print("ERROR: Cant get storage context")
            return
        }
        
        let fetchDescriptor = FetchDescriptor<Record>(predicate: #Predicate { $0.id.uuidString == id })
        
        do {
            guard let record = try context.fetch(fetchDescriptor).first else {
                print("ERROR: Cant get record widh id \(id) from storage")
                return
            }
            context.delete(record)
        } catch {
            print("ERROR: Cant delete record with id \(id), error: \(error)")
            return
        }
    }
   
}
