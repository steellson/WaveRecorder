//
//  EditViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 15.12.2023.
//

import Foundation

//MARK: - Protocol

protocol EditViewModelProtocol: AnyObject {
    var didUpdated: (() -> Void)? { get set }
    
    var recordName: String { get }
    var recordedAt: Date { get }
        
    func renameRecord(withNewName name: String)
    func deleteRecord()
}


//MARK: - Impl

final class EditViewModel: EditViewModelProtocol {
    
    var didUpdated: (() -> Void)?
    
    var recordName: String {
        record.name
    }
    
    var recordedAt: Date {
        record.date
    }
    
    private var record: Record
    
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
    
    func renameRecord(withNewName name: String) {
        parentViewModel.renameRecord(withNewName: name) { [weak self] in
            self?.didUpdated?()
            self?.record.name = name
        }
    }
    
    func deleteRecord() {
        parentViewModel.deleteRecord() { [weak self] in
            self?.didUpdated?()
        }
    }
}
