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
    var shouldUpdateInterface: ((Bool) async -> Void)? { get set }
}

protocol ParentViewModelProtocol: AnyObject {
    func makeRecordView() -> IsolatedViewModule
    func makeEditViewModel(_ indexPath: IndexPath) -> EditViewModel
    func makePlayToolbarViewModel(_ indexPath: IndexPath) -> PlayToolbarViewModel
}

protocol Searcher: AnyObject {
    func resetData() async
    func search(withText text: String) async
}

protocol Editor: AnyObject {
    func rename(forIndexPath indexPath: IndexPath, newName name: String) async
    func delete(forIndexPath indexPath: IndexPath) async
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
    
    var shouldUpdateInterface: ((Bool) async -> Void)?
    
    var numberOfItems: Int = 0
    
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
        
        Task { await fetchAll() }
    }
    
    
    func makeRecordView() -> IsolatedViewModule {
        assemblyBuilder.get(subModule: .record(parentVM: self))
    }
    
    func makeEditViewModel(_ indexPath: IndexPath) -> EditViewModel {
        assemblyBuilder.getEditViewModel(
            withRecord: records[indexPath.item],
            indexPath: indexPath,
            parentViewModel: self
        )
    }
    
    func makePlayToolbarViewModel(_ indexPath: IndexPath) -> PlayToolbarViewModel {
        assemblyBuilder.getPlayToolbarViewModel(
            withRecord: records[indexPath.item],
            indexPath: indexPath,
            parentViewModel: self
        )
    }
}


//MARK: - Private

private extension MainViewModelImpl {
    
    func fetchAll() async {
        do {
            let records = try await audioRepository.fetchRecords()
            self.records = records.sorted(by: { $0.name > $1.name })
            self.numberOfItems = records.count
            
            await self.shouldUpdateInterface?(false)
        } catch {
            os_log("\(RErrors.cantGetRecordsFromStorage + " \(error)")")
        }
    }
}


//MARK: - Searcher

extension MainViewModelImpl {
        
    func resetData() async {
        await fetchAll()
    }

    
    func search(withText text: String) async {
        guard !text.isEmpty else {
            await fetchAll()
            return
        }
        do {
            let records = try await audioRepository.search(withText: text)
            self.records = records
            
            await self.fetchAll()
        } catch {
            os_log("\(RErrors.cantSearchRecordsWithText + text + " \(error)")")
        }
    }
}


//MARK: - Editor

extension MainViewModelImpl {

    func rename(forIndexPath indexPath: IndexPath, newName name: String) async {
        do {
            try await audioRepository.rename(
                record: records[indexPath.item],
                newName: name
            )
            let oldRecord = self.records[indexPath.item]
            let newRecord = AudioRecord(
                name: name,
                format: oldRecord.format,
                date: oldRecord.date,
                duration: oldRecord.duration
            )
            self.records[indexPath.item] = newRecord
        } catch {
            os_log("\(RErrors.cantRenameRecord + " \(error)")")
        }
    }

    
    func delete(forIndexPath indexPath: IndexPath) async {
        let record = records[indexPath.item]
        do {
            try await audioRepository.delete(record: record)
            self.records.remove(at: indexPath.item)
            
            await self.fetchAll()
            os_log("\(RLogs.recordDeleted + record.name)")
        } catch {
            os_log("\(RErrors.cantDeleteRecordWithName + record.name + " \(error)")")
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
            os_log("\(RErrors.notificationCouldntBeActivated)")
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
            os_log("\(RErrors.notificationCouldntBeRemoved)")
            return
        }
        
        notificationCenter.removeObserver(recievedFrom,
                                          name: name,
                                          object: nil)
    }
}
