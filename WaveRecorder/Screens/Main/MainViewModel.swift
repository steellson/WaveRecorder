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
    func didSwipedForDelete(forIndexPath indexPath: IndexPath)
}

protocol MainViewModel: InterfaceUpdatable, Searcher, Editor, Notifier, MainTableViewModel, ModuleMaker { }


//MARK: - Impl

final class MainViewModelImpl: MainViewModel {
    
    var shouldUpdateInterface: ((Bool) async throws -> Void)?
    
    var numberOfItems: Int = 0
    var tableViewCellHeight: CGFloat = 200
    
    private var records: [AudioRecord] = []
    
    private let audioRepository: AudioRepository
    private let audioPlayer: AudioPlayer
    private let helpers: HelpersStorage
    private let coordinator: Coordinator
  
    
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
        
        Task { try await updateData() }
    }

    
    func didSwipedForDelete(forIndexPath indexPath: IndexPath) {
        Task { try await delete(record: records[indexPath.row]) }
    }
}


//MARK: Module Maker

extension MainViewModelImpl {
    
    func makeRecordBar() -> RecordBarView {
        let recordViewModel: RecordViewModel = RecordBarViewModelImpl(parentViewModel: self)
        let recordBarView = RecordBarView(viewModel: recordViewModel)
        return recordBarView
    }
    
    func makeEditViewModel(withIndexPath indexPath: IndexPath) -> EditViewModel {
        EditViewModelImpl(
            record: records[indexPath.row],
            helpers: helpers,
            parentViewModel: self
        )
    }
    
    func makePlayToolbarViewModel(withIndexPath indexPath: IndexPath) -> PlayToolbarViewModel {
        PlayToolbarViewModelImpl(
            record: records[indexPath.row],
            audioPlayer: audioPlayer,
            helpers: helpers,
            parentViewModel: self
        )
    }
}


//MARK: - Searcher

extension MainViewModelImpl {
        
    func updateData() async throws {
        do {
            let records = try await audioRepository.fetchRecords()
            self.records = records.sorted(by: { $0.name > $1.name })
            self.numberOfItems = records.count
            
            try await self.shouldUpdateInterface?(false)
        } catch {
            os_log("\(RErrors.cantGetRecordsFromStorage + " \(error)")")
        }
    }

    
    func search(withText text: String) async throws {
        guard !text.isEmpty else { return }

        do {
            let searchedRecords = try await audioRepository.search(withText: text)
            
            guard searchedRecords.count > 0 else {
                os_log("\(RLogs.searchedRecordsEmpty)")
                try await self.updateData()
                return
            }
            
            self.records = searchedRecords
            self.numberOfItems = records.count
            try await self.shouldUpdateInterface?(false)
        } catch {
            os_log("\(RErrors.cantSearchRecordsWithText + text + " \(error)")")
        }
    }
}


//MARK: - Editor

extension MainViewModelImpl {

    func rename(record: AudioRecord, newName name: String) async throws {
        do {
            try await audioRepository.rename(
                record: record,
                newName: name
            )
            try await self.updateData()
        } catch {
            os_log("\(RErrors.cantRenameRecord + " \(error)")")
        }
    }

    
    func delete(record: AudioRecord) async throws {
        do {
            try await audioRepository.delete(record: record)
            try await self.updateData()
            
            os_log("\(RLogs.recordDeleted + record.name)")
        } catch {
            os_log("\(RErrors.cantDeleteRecordWithName + record.name + " \(error)")")
        }
    }
    
    func openDetails(withAudioRecord record: AudioRecord) {
        coordinator.showRedactorView(withAudioRecord: record)
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
