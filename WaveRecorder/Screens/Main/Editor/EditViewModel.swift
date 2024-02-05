//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation

//MARK: - Protocols

protocol EditViewModel: AnyObject {
    var recordName: String { get }
    var recordedAt: String { get }
    var isEditing: Bool { get }
            
    func switchEditing()
    func onEndEditing(withNewName newName: String) async
}



//MARK: - Impl

final class EditViewModelImpl: EditViewModel {
        
    var recordName: String {
        formatter.formatName(record.name)
    }
    
    var recordedAt: String {
        formatter.formatDate(record.date)
    }
    
    private(set) var isEditing = false
    
    private var record: AudioRecord
    private let indexPath: IndexPath
    
    private let parentViewModel: MainViewModel
    
    private let formatter: FormatterProtocol
    
    
    //MARK: Init
    
    init(
        record: AudioRecord,
        indexPath: IndexPath,
        formatter: FormatterProtocol,
        parentViewModel: MainViewModel
    ) {
        self.record = record
        self.indexPath = indexPath
        self.formatter = formatter
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
        
        guard newName != record.name else { return }
        
        await parentViewModel.rename(forIndexPath: indexPath, newName: newName)
        
        self.record = AudioRecord(
            name: newName,
            format: record.format,
            date: record.date,
            duration: record.duration
        )
    }
}

