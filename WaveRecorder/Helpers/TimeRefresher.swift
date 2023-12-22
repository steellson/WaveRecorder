//
//  TimeRefresher.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 20.12.2023.
//

import Foundation


typealias TimeRefresherAction = () -> Void

//MARK: - Protocol

protocol TimeRefresherProtocol: AnyObject {
    var isRunning: Bool { get }
    
    func register(_ action: @escaping TimeRefresherAction)
    func start()
    func stop()
}


//MARK: - Impl

final class TimeRefresher: TimeRefresherProtocol  {

    private var timer: Timer? = nil
    private var action: TimeRefresherAction? = nil

    var isRunning: Bool = false

}

//MARK: - Public

extension TimeRefresher {
    
    func register(_ action: @escaping TimeRefresherAction) {
        self.action = action
        guard timer == nil else {
            return
        }
    }

    func start() {
        guard action != nil else {
            return
        }
        stop()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            self.tick()
        })
    }

    func stop() {
        guard let timer = timer else {
            return
        }
        isRunning = false
        timer.invalidate()
        self.timer = nil
    }
}


//MARK: - Private

private extension TimeRefresher {
    
    private func tick() {
        guard let action = action else {
            stop()
            print("ERROR: TimeRefresher action is not registered!")
            return
        }
        action()
    }
}
