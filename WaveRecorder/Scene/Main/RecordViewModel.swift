//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation

//MARK: - Protocol

protocol RecordViewModelProtocol: AnyObject {
    var buttonRadius: CGFloat { get }
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {

    private(set) var buttonRadius: CGFloat = 30.0
    
    private lazy var recordWillNamed: String = {
        "Record_\((self.parentViewModel?.records.count ?? 0) + 1)"
    }()
    
    private weak var parentViewModel: MainViewModelProtocol?
    
    init(
        parentViewModel: MainViewModelProtocol
    ) {
        self.parentViewModel = parentViewModel
    }
}


//MARK: - Public

extension RecordViewModel {
    
  
}
