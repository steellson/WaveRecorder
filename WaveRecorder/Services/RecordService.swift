//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import AVFoundation


//MARK: - Protocol

protocol RecordServiceProtocol: AnyObject {
    func startRecord()
    func stopRecord(completion: ((Record?) -> Void)?)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    var isAudioRecordingAllowed = false
    
    private var record: Record?
        
    private var format: AudioFormat = .m4a
    
    private let fileManagerInstance = FileManager.default
    
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    
    
    init() {
        setupAudioRecorder()
    }
}


//MARK: - Private

private extension RecordService {
    
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
    
    func setupRecordName() -> String {
        let documentsPath = fileManagerInstance
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .path()
        
        do {
            let count = try fileManagerInstance
                .contentsOfDirectory(atPath: documentsPath)
                .count
            return "Record-\(count + 1)"
        } catch {
            return "Record-1"
        }
    }
}


//MARK: - Public

extension RecordService {
    
    //MARK: Start
    
    func startRecord() {
        guard
            isAudioRecordingAllowed
        else {
            print("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        let recordWillNamed = setupRecordName()
        
        let storedURL = fileManagerInstance
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recordWillNamed)
            .appendingPathExtension(format.rawValue)
        
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
                    format: format.rawValue,
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
    
    
    //MARK: Stop
    
    func stopRecord(completion: ((Record?) -> Void)?) {
        DispatchQueue.global().async { [unowned self] in
            
            // Set duration
            let duration = self.audioRecorder.currentTime
            self.record?.duration = duration
            
            // Stop recording
            self.audioRecorder.stop()
            
            // Check
            !self.audioRecorder.isRecording
            ? print(">>> RECORD FINISHED!")
            : print(">>> RECORD IS NOT STOPPED! SOMETHING WRONG")
            
            // Remove recorder
            self.audioRecorder = nil

            // Send record
            completion?(self.record)
        }
    }
}

