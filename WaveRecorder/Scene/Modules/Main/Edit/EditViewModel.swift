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
    var recordedAt: Date { get }
    var isEditing: Bool { get }
            
    func switchEditing()
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
    
    private(set) var isEditing = false
    
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
    
    func switchEditing() {
        isEditing.toggle()
    }

    func onEndEditing(withNewName newName: String) {
        isEditing = false
        guard newName != record.name else { return }
        renameRecord(withNewName: newName.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}


//MARK: - Private

private extension EditViewModel {
    
    func renameRecord(withNewName name: String) {
        parentViewModel.renameRecord(withNewName: name)
        record.name = String(unicodeScalarLiteral: name)
    }
}
