//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation
import WRAudio


//MARK: - Impl

final class EditViewModelImpl {
    
    private let helpers: HelpersStorage
    private let parentViewModel: MainViewModel
    
    private var record: AudioRecord
    private var isEditing: Bool = false

    
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

//MARK: - Input

extension EditViewModelImpl: EditViewProtocol {
        
    func editDidTapped() {
        isEditing.toggle()
    }
    
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
    
    func addToVideoButtonTapped() {
        parentViewModel.openDetails(withAudioRecord: record)
    }
}


//MARK: Output

extension EditViewModelImpl: EditViewModel {
    
    func isEditingNow() -> Bool {
        isEditing
    }
    
    func getRecordName() -> String {
        helpers.formatter.formatName(record.name)
    }
    
    func getCreatinonDateString() -> String {
        helpers.formatter.formatDate(record.date)
    }
}
