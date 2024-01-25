//
//  RecordCellViewModelImpl.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol RecordCellViewModel: AnyObject {
    func renameRecord(withNewName: String) async
    func deleteRecord() async
    
    func makeEditViewModel() -> EditViewModelProtocol
    func makePlayViewModel() -> PlayToolbarViewModel
}


//MARK: - Impl

final class RecordCellViewModelImpl: RecordCellViewModel {
               
    private let indexPath: IndexPath
    private let record: AudioRecord
    private let parentViewModel: MainViewModel
    private let assemblyBuilder: AssemblyProtocol
    
    enum ChildViewModelType {
        case editor
        case player
    }
    
    
    //MARK:  Init
    
    init(
        indexPath: IndexPath,
        record: AudioRecord,
        parentViewModel: MainViewModel,
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
    
    func makePlayViewModel() -> PlayToolbarViewModel {
        assemblyBuilder.getPlayViewModel(withRecord: record, parentViewModel: self)
    }
}

extension RecordCellViewModelImpl {
    
    //MARK: Rename

    func renameRecord(withNewName name: String) async {
        await parentViewModel.rename(forIndexPath: indexPath, newName: name)
    }
    
    
    //MARK: Delete
    
    func deleteRecord() async {
        await parentViewModel.delete(forIndexPath: indexPath)
    }
}
