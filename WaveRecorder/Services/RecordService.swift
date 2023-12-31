//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import AVFoundation
import OSLog



//MARK: - Protocols

protocol RecordServiceProtocol: AnyObject {
    func startRecord()
    func stopRecord(completion: ((Record?) -> Void)?)
}

protocol RecordServiceRepresentative: AnyObject {
    func record(isRecording: Bool)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    private var isAudioRecordingAllowed = false
    
    private var record: Record?
    private var format: AudioFormat = .m4a
    
    private var audioRecorder: AVAudioRecorder!
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private let fileManager: FileManager
    
    init(
        fileManager: FileManager
    ) {
        self.fileManager = fileManager
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
                        os_log("ERROR: Audio permission is not allowed!")
                        self.isAudioRecordingAllowed = false
                    } else {
                        os_log("SUCCESS: Audio permission allowed!")
                        self.isAudioRecordingAllowed = true
                    }

                }
            }
        } catch {
            os_log("ERROR: Cant setup audio recorder. \(error)")
        }
    }
    
    func setupRecordName() -> String {
        let documentsPath = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .path()
        
        let defaultPrefix = "Record-"
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            
            if !files.isEmpty {
                let maxRecords = files
                    .compactMap { file in
                        if file.hasPrefix(defaultPrefix) {
                            let postfix = file
                                .components(separatedBy: "-")
                                .last
                            return postfix?
                                .components(separatedBy: ".")
                                .first
                        } else {
                            return nil
                        }
                    }
                    .compactMap { Int($0) }
                    .max()
                
                return defaultPrefix + String(((maxRecords ?? 0) + 1))
            }
        } catch {
            return defaultPrefix + String(1)
        }
        return defaultPrefix + String(1)
    }
    
    func setupSettings() -> [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
}


//MARK: - Public

extension RecordService {
    
    //MARK: Start
    
    func startRecord() {
        // Check permissions
        guard
            isAudioRecordingAllowed
        else {
            os_log("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        // Prepare
        let settings = setupSettings()
        let recordWillNamed = setupRecordName()
        let storedURL = URLBuilder.buildURL(
            forRecordWithName: recordWillNamed,
            andFormat: format.rawValue
        )
        
        // Process
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.audioSession.setActive(true)
                try self.audioSession.setCategory(.record)
                
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
                
                // Check result
                self.audioRecorder.isRecording
                ? os_log(">>> RECORD STARTED!")
                : os_log(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
                
            } catch {
                self.stopRecord(completion: nil)
                os_log("ERROR: Cant initialize audio recorder")
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
            ? os_log(">>> RECORD FINISHED!")
            : os_log(">>> RECORD IS NOT STOPPED! SOMETHING WRONG")
            
            // Reset category back
            do {
                try self.audioSession.setCategory(.playback)
            } catch {
                os_log("ERROR: Couldnt reset audio session category after record. \(error)")
            }
            
            // Remove recorder
            self.audioRecorder = nil

            // Send record
            completion?(self.record)
        }
    }
}

