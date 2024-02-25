//
//  PlayToolbarConfigurator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//

import Foundation


//MARK: - View

protocol PlayToolbarViewProtocol: AnyObject {
    func goBack() throws
    func play(atTime time: Float, animation: @escaping () -> Void) throws
    func stop() throws
    func goForward() throws
    func deleteRecord() throws
}


//MARK: - ViewModel

protocol PlayToolbarViewModel: PlayToolbarViewProtocol {
    func isPlayingNow() -> Bool
    func getProgress() -> Float
    func getDuration() -> Float
    func getElapsedTimeString() -> String
    func getRemainingTimeString() -> String
}
