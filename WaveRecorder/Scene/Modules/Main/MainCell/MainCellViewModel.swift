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
    func renameRecord(withNewName: String)
    func deleteRecord()
    
    func makeEditViewModel() -> EditViewModelProtocol
    func makePlayViewModel() -> PlayViewModelProtocol
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {
               
    private let record: Record
    private let indexPath: IndexPath
    private let parentViewModel: MainViewModelProtocol

    
    enum ChildViewModelType {
        case editor
        case player
    }
    
    
    init(
        record: Record,
        indexPath: IndexPath,
        parentViewModel: MainViewModelProtocol
    ) {
        self.record = record
        self.indexPath = indexPath
        self.parentViewModel = parentViewModel
    }
    
    
    func makeEditViewModel() -> EditViewModelProtocol {
        AssemblyBuilder.getEditViewModel(withRecord: record, parentViewModel: self)
    }
    
    func makePlayViewModel() -> PlayViewModelProtocol {
        AssemblyBuilder.getPlayViewModel(withRecord: record, parentViewModel: self)
    }
}


//MARK: - Public

extension MainCellViewModel {

    func renameRecord(withNewName name: String) {
        parentViewModel.rename(recordForIndexPath: indexPath, newName: name)
    }
    
    func deleteRecord() {
        parentViewModel.delete(recordForIndexPath: indexPath)
    }
}
