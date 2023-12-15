//
//  MainCellViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol MainCellViewModelProtocol: AnyObject {
    
    func deleteRecord(completion: @escaping () -> Void)
    func renameRecord(withNewName: String, completion: @escaping () -> Void)
    
    func makePlayViewModel() -> PlayViewModelProtocol
    func makeEditViewModel() -> EditViewModelProtocol
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {
        
    private let record: Record
    
    private weak var parentViewModel: MainViewModelProtocol?
    
    init(
        record: Record,
        parentViewModel: MainViewModelProtocol
    ) {
        self.record = record
        self.parentViewModel = parentViewModel
    }
    
    func makePlayViewModel() -> PlayViewModelProtocol {
        AssemblyBuilder.getPlayViewModel(withParentViewModel: self, record: record)
    }
    
    func makeEditViewModel() -> EditViewModelProtocol {
       AssemblyBuilder.getEditViewModel(withParentViewModel: self, record: record)
    }
}


//MARK: - Public

extension MainCellViewModel {
    
    func deleteRecord(completion: @escaping () -> Void) {
        parentViewModel?.delete(record: record) { isDeleted in
            if isDeleted {
                completion()
            }
        }
    }
    
    func renameRecord(withNewName name: String, completion: @escaping () -> Void) {
        parentViewModel?.rename(record: record, newName: name) { isRenamed in
            if isRenamed {
                completion()
            }
        }
    }
}
