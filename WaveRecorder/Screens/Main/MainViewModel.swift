//
//  MainViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 23.11.2023.
//

import Foundation
import OSLog
import WRAudio
import WRResources


//MARK: - Protocols

protocol InterfaceUpdatable: AnyObject {
    var shouldUpdateInterface: ((Bool) async -> Void)? { get set }
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

protocol MainTableViewModel: AnyObject {
    var numberOfItems: Int { get }
    var tableViewCellHeight: CGFloat { get }
}

protocol MainViewModel: InterfaceUpdatable, Searcher, Editor, Notifier, MainTableViewModel {
    func makeRecordBar() -> RecordBarView
    func makeEditView(indexPath: IndexPath) -> EditView?
    func makePlayToolbarView(indexPath: IndexPath) -> PlayToolbarView?
}


//MARK: - Impl

final class MainViewModelImpl: MainViewModel {
    
    var shouldUpdateInterface: ((Bool) async -> Void)?
    
    var numberOfItems: Int = 0
    
    var tableViewCellHeight: CGFloat = 200

    
    private var records: [AudioRecord] = []
    
    private let audioRepository: AudioRepository
    private let notificationCenter: NotificationCenter
    private let coordinator: Coordinator
    
    
    //MARK: Init
    
    init(
        audioRepository: AudioRepository,
        notificationCenter: NotificationCenter,
        coordinator: Coordinator
    ) {
        self.audioRepository = audioRepository
        self.notificationCenter = notificationCenter
        self.coordinator = coordinator
        
        Task { await fetchAll() }
    }
    
    
    //MARK: Make childs
    
    func makeRecordBar() -> RecordBarView {
        let recordViewModel: RecordViewModel = RecordBarViewModelImpl(parentViewModel: self)
        let recordBarView = RecordBarView(viewModel: recordViewModel)
        return recordBarView
    }
    
    func makeEditView(indexPath: IndexPath) -> EditView? {
        guard records.count > indexPath.row else { return nil }
        let editViewModel: EditViewModel = EditViewModelImpl(
            record: records[indexPath.row],
            indexPath: indexPath,
            formatter: HelpersStorage.formatter,
            parentViewModel: self
        )
        let editView = EditView(viewModel: editViewModel)
        return editView
    }
    
    func makePlayToolbarView(indexPath: IndexPath) -> PlayToolbarView? {
        guard records.count > indexPath.row else { return nil }
        let playToolbarViewModel: PlayToolbarViewModel = PlayToolbarViewModelImpl(
            record: records[indexPath.row],
            indexPath: indexPath,
            audioPlayer: AudioPlayerImpl(),
            timeRefresher: HelpersStorage.timeRefresher,
            formatter: HelpersStorage.formatter,
            parentViewModel: self
        )
        let playToolbarView = PlayToolbarView(viewModel: playToolbarViewModel)
        return playToolbarView
    }
}


//MARK: - Updating data (Private)

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
        guard !text.isEmpty else { return }

        do {
            self.records = try await audioRepository.search(withText: text)
            await self.shouldUpdateInterface?(false)
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
