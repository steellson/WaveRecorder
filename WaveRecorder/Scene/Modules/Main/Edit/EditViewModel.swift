//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation

//MARK: - Protocol

protocol EditViewModelProtocol: AnyObject {
    var recordName: String { get }
    var recordedAt: Date { get }
    var isEditing: Bool { get }
            
    func switchEditingMode()
    func onEndEditing(withNewName newName: String)
}


//MARK: - Impl

final class EditViewModel: EditViewModelProtocol {
        
    var recordName: String {
        record.name
    }
    
    var recordedAt: Date {
        record.date
    }
    
    var isEditing = false
    
    private let record: Record
    
    private let parentViewModel: MainCellViewModelProtocol
    
    init(
        parentViewModel: MainCellViewModelProtocol,
        record: Record
    ) {
        self.parentViewModel = parentViewModel
        self.record = record
    }
}


//MARK: - Public

extension EditViewModel {

    func switchEditingMode() {
        isEditing.toggle()
    }
    
    func onEndEditing(withNewName newName: String) {
        parentViewModel.renameRecord(withNewName: newName)
    }
}


//MARK: - Private

private extension EditViewModel {
    
    func renameRecord(withNewName name: String) {
        isEditing = true
        parentViewModel.renameRecord(withNewName: name)
        record.name = String(unicodeScalarLiteral: name)
        isEditing = false
    }
}
