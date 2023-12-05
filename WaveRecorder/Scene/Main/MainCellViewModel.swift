//
//  MainCellViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 28.11.2023.
//

import Foundation

//MARK: - Protocol

protocol MainCellViewModelProtocol: AnyObject {
    var record: Record? { get set }
}


//MARK: - Impl

final class MainCellViewModel: MainCellViewModelProtocol {
    
    var record: Record?
    
    private weak var parentViewModel: MainViewModelProtocol?

    
    init(
        parentViewModel: MainViewModelProtocol
    ) {
        self.parentViewModel = parentViewModel
    }
}


//MARK: - Public

extension MainCellViewModel {
    
  
}
