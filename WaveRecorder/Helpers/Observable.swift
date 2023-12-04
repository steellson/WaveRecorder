//
//  Observable.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 04.12.2023.
//

import Foundation

final class Observable<T> {
    
    var value: T {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.listener?(self.value)
            }
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(
        value: T
    ) {
        self.value = value
    }
    
    
    func bind(to listener: @escaping (T) -> Void) {
        listener(value)
        self.listener = listener
    }
}
