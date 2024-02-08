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

protocol MainTableViewModel: AnyObject {
    var numberOfItems: Int { get }
    var tableViewCellHeight: CGFloat { get }
    func didTappedOnCell(withIndexPath indexPath: IndexPath)
    func didSwipedForDelete(forIndexPath indexPath: IndexPath)
}

protocol MainViewModel: InterfaceUpdatable, Searcher, Editor, Notifier, MainTableViewModel, ModuleMaker { }


//MARK: - Impl

final class MainViewModelImpl: MainViewModel {
    
    var shouldUpdateInterface: ((Bool) async -> Void)?
    
    var numberOfItems: Int = 0
    var tableViewCellHeight: CGFloat = 200
    
    private var records: [AudioRecord] = []
    
    private let audioRepository: AudioRepository
    private let audioPlayer: AudioPlayer
    private let helpers: HelpersStorage
    private let coordinator: Coordinator
    
    private lazy var editViewModel: EditViewModel = {
        EditViewModelImpl(
            helpers: helpers,
            parentViewModel: self
        )
    }()
    
    private lazy var playToolbarViewModel: PlayToolbarViewModel = {
        PlayToolbarViewModelImpl(
            audioPlayer: audioPlayer,
            helpers: helpers,
            parentViewModel: self
        )
    }()
        
    
    //MARK: Init
    
    init(
        audioRepository: AudioRepository,
        audioPlayer: AudioPlayer,
        helpers: HelpersStorage,
        coordinator: Coordinator
    ) {
        self.audioRepository = audioRepository
        self.audioPlayer = audioPlayer
        self.helpers = helpers
        self.coordinator = coordinator
        
        Task { await fetchAll() }
    }
    
    
    func didTappedOnCell(withIndexPath indexPath: IndexPath) {
        let selectedRecord = records[indexPath.row]
        editViewModel.update(record: selectedRecord)
        playToolbarViewModel.update(record: selectedRecord)
    }
    
    func didSwipedForDelete(forIndexPath indexPath: IndexPath) {
        Task { await delete(record: records[indexPath.row]) }
    }
}


//MARK: Module Maker

extension MainViewModelImpl {
    
    func makeRecordBar() -> RecordBarView {
        let recordViewModel: RecordViewModel = RecordBarViewModelImpl(parentViewModel: self)
        let recordBarView = RecordBarView(viewModel: recordViewModel)
        return recordBarView
    }
    
    func makeEditView(withIndexPath indexPath: IndexPath) -> EditView? {
        guard records.count > indexPath.row else { return nil }
        editViewModel.update(record: records[indexPath.row])
        return EditView(viewModel: editViewModel)
    }
    
    func makePlayToolbarView(withIndexPath indexPath: IndexPath) -> PlayToolbarView? {
        guard records.count > indexPath.row else { return nil }
        playToolbarViewModel.update(record: records[indexPath.row])
        return PlayToolbarView(viewModel: playToolbarViewModel)
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

    func rename(record: AudioRecord, newName name: String) async {
        do {
            try await audioRepository.rename(
                record: record,
                newName: name
            )
            let newRecord = AudioRecord(
                name: name,
                format: record.format,
                date: record.date,
                duration: record.duration
            )
            
            guard let oldRecordIndex = self.records.firstIndex(of: record) else {
                os_log("\(RErrors.cantRenameRecord)")
                return
            }
            
            self.editViewModel.update(record: newRecord)
            self.playToolbarViewModel.update(record: newRecord)
            self.records[oldRecordIndex] = newRecord
            
        } catch {
            os_log("\(RErrors.cantRenameRecord + " \(error)")")
        }
    }

    
    func delete(record: AudioRecord) async {
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
        
        helpers.notificationCenter.addObserver(recievedFrom,
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
        
        helpers.notificationCenter.removeObserver(recievedFrom,
                                          name: name,
                                          object: nil)
    }
}
