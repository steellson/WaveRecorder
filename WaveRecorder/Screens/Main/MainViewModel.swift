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

protocol ParentViewModelProtocol: AnyObject {
    func makeRecordView() -> IsolatedViewModule
    func makeViewModelForCell(forIndexPath indexPath: IndexPath) -> RecordCellViewModel
}

protocol Searcher: AnyObject {
    func resetData()
    func search(withText text: String)
}

protocol Editor: AnyObject {
    func rename(forIndexPath indexPath: IndexPath, newName name: String)
    func delete(forIndexPath indexPath: IndexPath)
}

protocol Notifier: AnyObject {
    func activateNotification(withName name: NSNotification.Name, selector: Selector, from: Any?)
    func removeNotification(withName name: NSNotification.Name, from: Any?)
}

protocol MainViewModel: InterfaceUpdatable, ParentViewModelProtocol, Searcher, Editor, Notifier {
    var numberOfItems: Int { get }
    var tableViewCellHeight: CGFloat { get }
}


//MARK: - Impl

final class MainViewModelImpl: MainViewModel {
    
    var shouldUpdateInterface: ((Bool) -> Void)?
    
    var numberOfItems: Int {
        records.count
    }
    
    var tableViewCellHeight: CGFloat = 200

    
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


//MARK: - Private

private extension MainViewModelImpl {
    
    func fetchAll() {
        records = [
            AudioRecord(name: "1212", format: .aac, date: .now, duration: 222),
            AudioRecord(name: "sdfe", format: .aac, date: .now, duration: 3)
        ]
        shouldUpdateInterface?(false)
        
        
//        audioRepository.fetchRecords { [unowned self] result in
//            switch result {
//            case .success(let records):
//                self.records = records
//                self.shouldUpdateInterface?(false)
//            case .failure(let error):
//                os_log("\(R.Strings.Errors.cantGetRecordsFromStorage.rawValue + " \(error)")")
//            }
//        }
    }
}


//MARK: - Searcher

extension MainViewModelImpl {
        
    func resetData() {
        fetchAll()
    }

    
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
}

//MARK: - Editor

extension MainViewModelImpl {

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

extension MainViewModelImpl {
    
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
