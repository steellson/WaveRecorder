//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation
import WRAudio


//MARK: - Protocols

protocol EditViewModel: ChildViewModel {
    var recordName: String { get }
    var recordedAt: String { get }
    var isEditing: Bool { get }
            
    func switchEditing()
    func onEndEditing(withNewName newName: String) async
}



//MARK: - Impl

final class EditViewModelImpl: EditViewModel {
        
    var recordName: String {
        helpers.formatter.formatName(record?.name ?? "error")
    }
    
    var recordedAt: String {
        helpers.formatter.formatDate(record?.date ?? .now)
    }
    
    private(set) var isEditing = false
    
    private var record: AudioRecord?
    private let helpers: HelpersStorage
    private let parentViewModel: MainViewModel
    
    
    
    //MARK: Init
    
    init(
        record: AudioRecord? = nil,
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

    func onEndEditing(withNewName newName: String) async {
        isEditing = false
        
        guard 
            let record,
            newName != record.name
        else {
            return
        }
        
        await parentViewModel.rename(record: record, newName: newName)
        
        self.record = AudioRecord(
            name: newName,
            format: record.format,
            date: record.date,
            duration: record.duration
        )
    }
}

//MARK: - Child

extension EditViewModelImpl {
    
    func update(record: AudioRecord) {
        self.record = record
    }
}
