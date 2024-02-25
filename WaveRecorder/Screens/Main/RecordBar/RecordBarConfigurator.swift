//
//  RecordBarConfigurator.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 25.02.2024.
//

import UIKit


//MARK: - View

protocol RecordBarViewProtocol: AnyObject {
    func recordButtonTapped(_ isRecording: Bool)
}


//MARK: - ViewModel

protocol RecordBarViewModel: AnyObject {
    func setupRecordAnimated(_ isRecording: Bool) async throws
}
