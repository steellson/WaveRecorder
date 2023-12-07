//
//  RecordViewModel.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 24.11.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol RecordViewModelProtocol: AnyObject {
    var record: Record? { get }
    var isAudioRecordingAllowed: Bool { get }

    func record(isRecording: Bool)
    func didRecorded()
}


//MARK: - Impl

final class RecordViewModel: RecordViewModelProtocol {
    
    var record: Record?
    
    var isAudioRecordingAllowed = false
    
    private lazy var recordWillNamed: String = {
        "Record_\((self.parentViewModel?.records.count ?? 0) + 1)"
    }()
    
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    
    private weak var parentViewModel: MainViewModelProtocol?
    
    init(
        parentViewModel: MainViewModelProtocol
    ) {
        self.parentViewModel = parentViewModel
        
        setupAudioRecorder()
    }
}


//MARK: - Public

extension RecordViewModel {
    
    func record(isRecording: Bool) {
        if isRecording {
            stopRecord(completion: nil)
            didRecorded()
            parentViewModel?.recordStarted?(false)
        } else {
            startRecord()
            parentViewModel?.recordStarted?(true)
        }
    }
    
    func didRecorded() {
        guard let record else {
            print("ERROR: Cant send record to MainViewModel. Reason: Record is nil")
            return
        }
        
        if let parentVM = parentViewModel {
            parentVM.importRecord(record)
        } else {
            print("ERROR: Cant send record to MainViewModel. Reason: ParentViewModel is nil")
        }
    }
}



//MARK: - Private

private extension RecordViewModel {
    
    func setupAudioRecorder() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            AVAudioApplication.requestRecordPermission() { allowed in
                DispatchQueue.main.async { [unowned self] in
                    
                    if !allowed {
                        print("ERROR: Audio permission is not allowed!")
                        self.isAudioRecordingAllowed = false
                    } else {
                        print("SUCCESS: Audio permission allowed!")
                        self.isAudioRecordingAllowed = true
                    }

                }
            }
        } catch {
            print("ERROR: Cant setup audio recorder. \(error)")
        }
    }
    
    
    func startRecord() {
        guard 
            isAudioRecordingAllowed
        else {
            print("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        let storedURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recordWillNamed)
            .appendingPathExtension("m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.audioSession.setActive(true)
                self.audioRecorder = try AVAudioRecorder(url: storedURL, settings: settings)
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()
                
                let record = Record(
                    name: recordWillNamed,
                    date: .now,
                    url: storedURL,
                    duration: nil
                )
                self.record = record
                
                // Check
                self.audioRecorder.isRecording
                ? print(">>> RECORD STARTED!")
                : print(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
            } catch {
                self.stopRecord(completion: nil)
                print("ERROR: Cant initialize audio recorder")
            }
        }
    }
    
    func stopRecord(completion: ((Record?) -> Void)?) {
        DispatchQueue.global().async { [unowned self] in
            self.audioRecorder.stop()
            
            do {
                try self.audioSession.setActive(false)
                print(">>> RECORD STOPPED!")
            } catch {
                print(">>> RECORD IS NOT STOPPED! SOMETHING WRONG. \(error)")
            }
            
            completion?(record)
        }
    }
}
