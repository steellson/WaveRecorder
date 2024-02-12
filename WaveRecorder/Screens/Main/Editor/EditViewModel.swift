//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation
import WRAudio


//MARK: - Protocols

protocol EditViewModel: AnyObject {
    var recordName: String { get }
    var recordedAt: String { get }
    var isEditing: Bool { get }
            
    func switchEditing()
    func onEndEditing(withNewName newName: String) async throws
    func addToVideoButtonTapped()
}



//MARK: - Impl

final class EditViewModelImpl: EditViewModel {
        
    var recordName: String {
        helpers.formatter.formatName(record.name)
    }
    
    var recordedAt: String {
        helpers.formatter.formatDate(record.date)
    }
    
    private(set) var isEditing = false
    
    private var record: AudioRecord
    private let helpers: HelpersStorage
    private let parentViewModel: MainViewModel
    
    
    
    //MARK: Init
    
    init(
        record: AudioRecord,
        helpers: HelpersStorage,
        parentViewModel: MainViewModel
    ) {
        self.record = record
        self.helpers = helpers
        self.parentViewModel = parentViewModel
    }
}

extension EditViewModelImpl {
    
    //MARK: Switch editing state
    
    func switchEditing() {
        isEditing.toggle()
    }
    
    
    //MARK: On end editing

    func onEndEditing(withNewName newName: String) async throws {
        isEditing = false
        
        guard newName != record.name else { return }
        
        try await parentViewModel.rename(record: record, newName: newName)
        
        self.record = AudioRecord(
            name: newName,
            format: record.format,
            date: record.date,
            duration: record.duration
        )
    }
    
    
    //MARK: Did details tapped
    
    func addToVideoButtonTapped() {
        parentViewModel.openDetails(withAudioRecord: record)
    }
}
