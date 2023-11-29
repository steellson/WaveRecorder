//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import Foundation
import AVFoundation

//MARK: - Protocol

protocol RecordServiceDelegate: AnyObject {
    
}

protocol RecordServiceProtocol: AnyObject {
    var delegate: RecordServiceDelegate? { get set }
    var isAudioRecordingAllowed: Bool { get }

    func startRecord()
    func stopRecord(success: Bool)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    weak var delegate: RecordServiceDelegate?
    
    var isAudioRecordingAllowed = false
        
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder = AVAudioRecorder()
    
    init() {
        setupAudioRecorder()
    }
   
    private func setupAudioRecorder() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            AVAudioApplication.requestRecordPermission() { [weak self] allowed in
                if !allowed {
                    print("ERROR: Audio permission is not allowed!")
                    self?.isAudioRecordingAllowed = false
                } else {
                    self?.isAudioRecordingAllowed = true
                }
            }
        } catch {
            print("ERROR: Cant setup audio recorder. \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


//MARK: - Public

extension RecordService {
   
    func startRecord() {
        guard isAudioRecordingAllowed else {
            print("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            stopRecord(success: false)
        }
    }
    
    func stopRecord(success: Bool) {
        audioRecorder.stop()
    }
}
