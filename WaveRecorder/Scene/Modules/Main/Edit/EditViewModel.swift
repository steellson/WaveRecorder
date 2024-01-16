//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation

//MARK: - Protocols

protocol EditViewModelProtocol: AnyObject {
    var recordName: String { get }
    var recordedAt: String { get }
    var isEditing: Bool { get }
            
    func switchEditing()
    func onEndEditing(withNewName newName: String)
}



//MARK: - Impl

final class EditViewModel: EditViewModelProtocol {
        
    var recordName: String {
        record.name
    }
    
    var recordedAt: String {
        formatter.formatDate(record.date)
    }
    
    private(set) var isEditing = false
    
    private let record: Record
    private let parentViewModel: MainCellViewModelProtocol
    
    private let formatter: FormatterProtocol
    
    
    //MARK: Init
    
    init(
        formatter: FormatterProtocol,
        parentViewModel: MainCellViewModelProtocol,
        record: Record
    ) {
        self.formatter = formatter
        self.parentViewModel = parentViewModel
        self.record = record
    }
}

extension EditViewModel {
    
    //MARK: Switch editing state
    
    func switchEditing() {
        isEditing.toggle()
    }
    
    
    //MARK: On end editing

    func onEndEditing(withNewName newName: String) {
        isEditing = false
        guard newName != record.name else { return }
        parentViewModel.renameRecord(withNewName: newName)
        record.name = String(unicodeScalarLiteral: newName)
    }
}

