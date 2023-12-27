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
               
    private let indexPath: IndexPath
    private let record: Record
    private let parentViewModel: MainViewModelProtocol
    private let assemblyBuilder: AssemblyProtocol
    
    enum ChildViewModelType {
        case editor
        case player
    }
    
    
    //MARK:  Init
    
    init(
        indexPath: IndexPath,
        record: Record,
        parentViewModel: MainViewModelProtocol,
        assemblyBuilder: AssemblyProtocol
    ) {
        self.indexPath = indexPath
        self.record = record
        self.parentViewModel = parentViewModel
        self.assemblyBuilder = assemblyBuilder
    }
    
    
    func makeEditViewModel() -> EditViewModelProtocol {
        assemblyBuilder.getEditViewModel(withRecord: record, parentViewModel: self)
    }
    
    func makePlayViewModel() -> PlayViewModelProtocol {
        assemblyBuilder.getPlayViewModel(withRecord: record, parentViewModel: self)
    }
}

extension MainCellViewModel {
    
    //MARK: Rename

    func renameRecord(withNewName name: String) {
        parentViewModel.rename(recordForIndexPath: indexPath, newName: name)
    }
    
    
    //MARK: Delete
    
    func deleteRecord() {
        parentViewModel.delete(recordForIndexPath: indexPath)
    }
}
