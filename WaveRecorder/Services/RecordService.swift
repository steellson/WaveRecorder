//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import AVFoundation
import OSLog



//MARK: - Protocol

protocol RecordServiceProtocol: AnyObject, Service {
    func startRecord()
    func stopRecord(completion: ((Record?) -> Void)?)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    private var isAudioRecordingAllowed = false
    
    private var record: Record?
    private var format: AudioFormat = .m4a
    
    private var audioRecorder: AVAudioRecorder!
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private let urlBuilder: URLBuilder
    private let fileManager: FileManager
    
    init(
        urlBuilder: URLBuilder,
        fileManager: FileManager
    ) {
        self.urlBuilder = urlBuilder
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
        
        guard audioRecorder == nil else { return }
        
        // Prepare
        let settings = setupSettings()
        let recordWillNamed = setupRecordName()
        let storedURL = urlBuilder.buildURL(
            forRecordWithName: recordWillNamed,
            andFormat: format.rawValue
        )
        
        // Process
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
            guard let strongSelf = self else { return }

            do {
                try strongSelf.audioSession.setActive(true)
                try strongSelf.audioSession.setCategory(.record)
                
                strongSelf.audioRecorder = try AVAudioRecorder(url: storedURL, settings: settings)
                strongSelf.audioRecorder.isMeteringEnabled = true
                strongSelf.audioRecorder.prepareToRecord()
                strongSelf.audioRecorder.record()
                os_log(">>> RECORD STARTED!")
                
                let record = Record(
                    name: recordWillNamed,
                    date: .now,
                    format: strongSelf.format.rawValue,
                    duration: nil
                )
                strongSelf.record = record
                
            } catch {
                strongSelf.stopRecord(completion: nil)
                os_log("ERROR: Cant initialize audio recorder")
            }
        }
    }
    
    
    //MARK: Stop
    
    func stopRecord(completion: ((Record?) -> Void)?) {
        guard audioRecorder != nil else { return }

        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
            guard let strongSelf = self else { return }
            
            // Set duration
            let duration = strongSelf.audioRecorder.currentTime
            strongSelf.record?.duration = duration
            
            // Stop recording
            strongSelf.audioRecorder.stop()
            os_log(">>> RECORD FINISHED!")
            
            // Reset category back
            do {
                try strongSelf.audioSession.setCategory(.playback)
            } catch {
                os_log("ERROR: Couldnt reset audio session category after record. \(error)")
            }
            
            // Remove recorder
            strongSelf.audioRecorder = nil

            // Send record
            completion?(strongSelf.record)
        }
    }
}

