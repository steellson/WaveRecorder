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
    
    private(set) var buttonRadius: CGFloat = 36.0
}


//MARK: - Public

extension MainViewModel {
    
}
