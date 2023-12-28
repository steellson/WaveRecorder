//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation
import OSLog


//MARK: - Protocols

protocol InterfaceUpdatable: AnyObject {
    var shouldUpdateInterface: ((Bool) -> Void)? { get set }
}

protocol Notifier: AnyObject {
    func activateNotification(withName name: NSNotification.Name, selector: Selector, from: Any?)
    func removeNotification(withName name: NSNotification.Name, from: Any?)
}

protocol MainViewModelProtocol: InterfaceUpdatable, StorageServiceRepresentative, Notifier {            
    func makeRecordView() -> IsolatedView
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var shouldUpdateInterface: ((Bool) -> Void)?
    
    var numberOfRecords: Int {
        records.count
    }
        
    private var records: [Record] = []
    
    private let assemblyBuilder: AssemblyProtocol
    private let storageService: StorageServiceProtocol
    private let notificationCenter: NotificationCenter

    
    //MARK: Init
    
    init(
        assemblyBuilder: AssemblyProtocol,
        storageService: StorageServiceProtocol,
        notificationCenter: NotificationCenter
    ) {
        self.assemblyBuilder = assemblyBuilder
        self.storageService = storageService
        self.notificationCenter = notificationCenter
        
        uploadRecords()
    }
    
    
    func makeRecordView() -> IsolatedView {
        assemblyBuilder.get(subModule: .record(parentVM: self))
    }
    
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> MainCellViewModelProtocol {
        assemblyBuilder.getMainCellViewModel(
            withRecord: records[indexPath.item],
            indexPath: indexPath
        )
    }
}


extension MainViewModel {
    
    //MARK: Upload
    
    func uploadRecords() {
        storageService.getRecords { [unowned self] result in
            switch result {
            case .success(let records):
                self.records = records
                self.shouldUpdateInterface?(false)
            case .failure(let error):
                os_log("\(R.Strings.Errors.cantGetRecordsFromStorage.rawValue + " \(error)")")
            }
        }
    }
    
    
    //MARK: Save
    
    func saveRecord(_ record: Record) {
        storageService.save(record: record) { [unowned self] _ in
            self.uploadRecords()
        }
    }
    
    
    //MARK: Get
    
    func getRecord(forIndexPath indexPath: IndexPath) -> Record {
        records[indexPath.item]
    }
    
    
    //MARK: Rename
    
    func rename(recordForIndexPath indexPath: IndexPath, newName name: String) {
        storageService.rename(
            record: records[indexPath.item],
            newName: name
        ) { [unowned self] isRenamed in
            
            switch isRenamed {
            case .success:
                self.records[indexPath.item].name = name
            case .failure(let error):
                os_log("\(R.Strings.Errors.cantRenameRecord.rawValue + " \(error)")")
            }
        }
    }
    
    //MARK: Search
    
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
                os_log("\(R.Strings.Errors.cantSearchRecordsWithText.rawValue + text + " \(error)")")
            }
        }
    }
    
    
    //MARK: Delete
    
    func delete(recordForIndexPath indexPath: IndexPath) {
        let record = records[indexPath.item]
        
        storageService.delete(record: record) { [unowned self] result in
            switch result {
            case .success:
                self.records.remove(at: indexPath.item)
                self.shouldUpdateInterface?(false)
                
                os_log("\(R.Strings.Logs.recordDeleted.rawValue + record.name)")
                
            case .failure(let error):
                os_log("\(R.Strings.Errors.cantDeleteRecordWithName.rawValue + record.name + " \(error)")")
            }
        }
    }
}

//MARK: Notifier

extension MainViewModel {
    
    func activateNotification(withName
                              name: NSNotification.Name,
                              selector: Selector, 
                              from: Any?) {
        guard 
            let recievedFrom = from
        else {
            os_log("\(R.Strings.Errors.notificationCouldntBeActivated.rawValue)")
            return
        }
        
        notificationCenter.addObserver(recievedFrom,
                                       selector: selector,
                                       name: name,
                                       object: nil)
        
    }
    
    
    func removeNotification(withName
                            name: NSNotification.Name,
                            from: Any?) {
        guard 
            let recievedFrom = from
        else {
            os_log("\(R.Strings.Errors.notificationCouldntBeRemoved.rawValue)")
            return
        }
        
        notificationCenter.removeObserver(recievedFrom,
                                          name: name,
                                          object: nil)
        
    }
}
