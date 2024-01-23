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

protocol TableViewRepresentative: AnyObject {
    var numberOfItems: Int { get }
    
    func fetchAll()
    func rename(forIndexPath indexPath: IndexPath, newName name: String)
    func search(withText text: String)
    func delete(forIndexPath indexPath: IndexPath)
}

protocol MainViewModelProtocol: InterfaceUpdatable, TableViewRepresentative, Notifier {
    func makeRecordView() -> IsolatedViewModule
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> RecordCellViewModel
}


//MARK: - Impl

final class MainViewModel: MainViewModelProtocol {
    
    var shouldUpdateInterface: ((Bool) -> Void)?
    
    var numberOfItems: Int {
        records.count
    }
    
    private var records: [AudioRecord] = []
    
    private let assemblyBuilder: AssemblyProtocol
    private let audioRepository: AudioRepository
    private let notificationCenter: NotificationCenter
    
    
    //MARK: Init
    
    init(
        assemblyBuilder: AssemblyProtocol,
        audioRepository: AudioRepository,
        notificationCenter: NotificationCenter
    ) {
        self.assemblyBuilder = assemblyBuilder
        self.audioRepository = audioRepository
        self.notificationCenter = notificationCenter
        
        fetchAll()
    }
    
    
    func makeRecordView() -> IsolatedViewModule {
        assemblyBuilder.get(subModule: .record(parentVM: self))
    }
    
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> RecordCellViewModel {
        assemblyBuilder.getMainCellViewModel(
            withRecord: records[indexPath.item],
            indexPath: indexPath
        )
    }
}


extension MainViewModel {
    
    //MARK: Upload
    
    func fetchAll() {
        audioRepository.fetchRecords { [unowned self] result in
            switch result {
            case .success(let records):
                self.records = records
                self.shouldUpdateInterface?(false)
            case .failure(let error):
                os_log("\(R.Strings.Errors.cantGetRecordsFromStorage.rawValue + " \(error)")")
            }
        }
    }
    
    
    //MARK: Rename
    
    func rename(forIndexPath indexPath: IndexPath, newName name: String) {
        audioRepository.rename(
            record: records[indexPath.item],
            newName: name
        ) { [unowned self] isRenamed in
            
            switch isRenamed {
            case .success:
                let oldRecord = self.records[indexPath.item]
                let newRecord = AudioRecord(
                    name: name,
                    format: oldRecord.format,
                    date: oldRecord.date,
                    duration: oldRecord.duration
                )
                self.records[indexPath.item] = newRecord
            case .failure(let error):
                os_log("\(R.Strings.Errors.cantRenameRecord.rawValue + " \(error)")")
            }
        }
    }
    
    //MARK: Search
    
    func search(withText text: String) {
        guard !text.isEmpty else {
            fetchAll()
            return
        }
        
        audioRepository.search(withText: text) { [unowned self] result in
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
    
    func delete(forIndexPath indexPath: IndexPath) {
        let record = records[indexPath.item]
        
        audioRepository.delete(record: record) { [unowned self] result in
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
