//
//  AudioRecorder.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import AVFoundation
import OSLog


//MARK: - Protocol

public protocol AudioRecorder: AnyObject {
    func startRecord() async throws
    func stopRecord() async throws -> AudioRecord?
}


//MARK: - Error

public enum AudioRecorderError: Error {
    case audioPermissionIsNotAllowed
    case cantSetupAudioRecorder
    case cantInitializeAudioRecorder
    case cantStartRecordAudio
    case cantStopAudioRecording
    case cantResetAudioSessionCategoryAfterRecord
}


//MARK: - Impl

final public class AudioRecorderImpl: AudioRecorder {
    
    private var isAudioRecordingAllowed = false
    
    private var record: AudioRecord?
    private var storedURL: URL?
    private var format: AudioFormat = .m4a
    
    private var audioRecorder: AVAudioRecorder!
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private let audioPathManager: AudioPathManager
    
    public init() {
        self.audioPathManager = AudioPathManagerImpl()
        
        do {
            try setupAudioRecorder()
        } catch {
            os_log("ERROR: Cant setup audio recorder. \(error)")
        }
    }
}


//MARK: - Private

private extension AudioRecorderImpl {
    
    func setupAudioRecorder() throws {
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
            throw AudioRecorderError.cantSetupAudioRecorder
        }
    }
    
    func setupSettings() -> [String: Any] {
        [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
}


//MARK: - Public

public extension AudioRecorderImpl {
    
    //MARK: Start
    
    func startRecord() async throws {
        // Check permissions
        guard
            isAudioRecordingAllowed
        else {
            os_log("ERROR: Cant start recording because it is not allowed!")
            throw AudioRecorderError.audioPermissionIsNotAllowed
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
        Task {
            do {
                try self.audioSession.setActive(true)
                try self.audioSession.setCategory(.record)
                
                self.audioRecorder = try AVAudioRecorder(url: storedURL, settings: settings)
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.record()
                
                if audioRecorder.isRecording {
                    os_log(">>> RECORD STARTED!")
                } else {
                    throw AudioRecorderError.cantStartRecordAudio
                }
                
                let record = AudioRecord(
                    name: recordWillNamed,
                    format: self.format,
                    date: .now,
                    duration: nil
                )
                self.record = record
                
            } catch {
                os_log("ERROR: Cant initialize audio recorder")
                throw AudioRecorderError.cantInitializeAudioRecorder
            }
        }
    }
    
    
    //MARK: Stop
    
    func stopRecord() async throws -> AudioRecord? {
        guard audioRecorder != nil else { return nil }
        return try? await Task {
            
            // Set duration
            let duration = self.audioRecorder.currentTime
            self.record?.duration = duration
            
            // Stop recording
            self.audioRecorder.stop()
            
            if !self.audioRecorder.isRecording {
                os_log(">>> RECORD FINISHED!")
            } else {
                throw AudioRecorderError.cantStopAudioRecording
            }
            
            // Reset category back
            do {
                try self.audioSession.setCategory(.playback)
            } catch {
                os_log("ERROR: Couldnt reset audio session category after record. \(error)")
                throw AudioRecorderError.cantResetAudioSessionCategoryAfterRecord
            }
            
            // Remove recorder
            self.audioRecorder = nil
            
            // Send record
            return self.record
        }.value
    }
}

