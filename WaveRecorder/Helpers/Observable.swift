//
//  Observable.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 04.12.2023.
//

import Foundation

final class Observable<T> {
    
    var value: T?
    
    var listener: ((T?) -> Void)?
    
    init(
        value: T? = nil
    ) {
        self.value = value
    }
    
    
    func bind(to listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}
