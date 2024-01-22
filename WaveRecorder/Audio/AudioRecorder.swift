//
//  AudioRecorder.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation
import AVFoundation
import OSLog



//MARK: - Protocol

protocol AudioRecorder: AnyObject {
    func startRecord()
    func stopRecord(completion: ((AudioRecord?) -> Void)?)
}


//MARK: - Impl

final class AudioRecorderImpl: AudioRecorder {
    
    private var isAudioRecordingAllowed = false
    
    private var record: AudioRecord?
    private var storedURL: URL?
    private var format: AudioFormat = .m4a
    
    private var audioRecorder: AVAudioRecorder!
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private let audioPathManager: AudioPathManager
    
    init() {
        self.audioPathManager = AudioPathManagerImpl()
        
        setupAudioRecorder()
    }
}


//MARK: - Private

private extension AudioRecorderImpl {
    
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

extension AudioRecorderImpl {
    
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
        let recordWillNamed = audioPathManager.createAudioRecordName()
        let storedURL = audioPathManager.createURL(
            forRecordWithName: recordWillNamed,
            andFormat: format.rawValue
        )
        self.storedURL = storedURL
        
        // Process
        do {
            try self.audioSession.setActive(true)
            try self.audioSession.setCategory(.record)
            
            self.audioRecorder = try AVAudioRecorder(url: storedURL, settings: settings)
            self.audioRecorder.isMeteringEnabled = true
            self.audioRecorder.prepareToRecord()
            self.audioRecorder.record()
            
            os_log(">>> RECORD STARTED!")
            
            let record = AudioRecord(
                name: recordWillNamed,
                format: self.format,
                date: .now,
                duration: nil
            )
            self.record = record
            
        } catch {
            self.stopRecord(completion: nil)
            os_log("ERROR: Cant initialize audio recorder")
        }
        
    }
    
    
    //MARK: Stop
    
    func stopRecord(completion: ((AudioRecord?) -> Void)?) {
        guard audioRecorder != nil else { return }
        
        // Set duration
        let duration = self.audioRecorder.currentTime
        self.record?.duration = duration
        
        // Stop recording
        self.audioRecorder.stop()
        os_log(">>> RECORD FINISHED!")
        
        // Reset category back
        do {
            try self.audioSession.setCategory(.playback)
        } catch {
            os_log("ERROR: Couldnt reset audio session category after record. \(error)")
        }
        
        // Set metadata
        self.applyMetadata(toAudioRecord: self.record)
        
        // Remove recorder
        self.audioRecorder = nil
        
        // Send record
        completion?(self.record)
        
    }
}


//MARK: - Metadata

private extension AudioRecorderImpl {
    
    typealias AudioMetadataValue = NSCopying & NSObjectProtocol
    
    func createMetadataItem(withKeyID keyID: AVMetadataIdentifier,
                            value: AudioMetadataValue) -> AVMutableMetadataItem {
        
        let item = AVMutableMetadataItem()
        item.identifier = keyID
        item.value = value
        
        return item
    }
    
    func createMetadataSet(forRecordModel recordModel: AudioRecord) -> [AVMutableMetadataItem] {
        [
            createMetadataItem(withKeyID: .id3MetadataTitleDescription, value: recordModel.name as AudioMetadataValue),
            createMetadataItem(withKeyID: .id3MetadataAudioEncryption, value: recordModel.format.rawValue as AudioMetadataValue),
            createMetadataItem(withKeyID: .id3MetadataDate, value: recordModel.date as AudioMetadataValue),
            createMetadataItem(withKeyID: .id3MetadataLength, value: String(recordModel.duration ?? 0) as AudioMetadataValue)
        ]
    }
    
    func applyMetadata(toAudioRecord record: AudioRecord?) {
        guard
            let storedURL,
            let record
        else {
            os_log("ATTENTION: Cannot set metadata to record! Stored URL is not found")
            return
        }
     
        let asset = AVAsset(url: storedURL)
    
        guard let exporter = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetPassthrough
            )
        else {
            return
        }
        
        exporter.metadata = createMetadataSet(forRecordModel: record)
        exporter.outputURL = audioPathManager.createURL(forRecordWithName: "test1", andFormat: "m4a")
        exporter.outputFileType = AVFileType.m4a
        
        exporter.exportAsynchronously {
            
            if exporter.status == .completed {
                os_log("✅ Export completed with metadata: \(String(describing: exporter.metadata))")
            } else if exporter.status == .failed {
                os_log("❌ Export failed with error: \(exporter.error)")
            } else {
                os_log("❔ Unknown export error! Status: \(exporter.status.rawValue)")
            }
            
        }
    }
}
