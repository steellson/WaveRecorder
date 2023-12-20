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
    
    func make(childModule: MainCellViewModel.ChildModule) -> PresentationUpdatable
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {
           
    private let record: Record
    private let indexPath: IndexPath
    private let parentViewModel: MainViewModelProtocol

    
    enum ChildModule {
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
    
    
    func make(childModule: ChildModule) -> PresentationUpdatable {
        switch childModule {
        case .editor: AssemblyBuilder.get(subModule: .edit(parentVM: self, record: record))
        case .player: AssemblyBuilder.get(subModule: .play(parentVM: self, record: record))
        }
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
