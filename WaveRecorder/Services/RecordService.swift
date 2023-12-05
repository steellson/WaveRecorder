//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import AVFoundation


//MARK: - Protocol

protocol RecordServiceProtocol: AnyObject {
    var isAudioRecordingAllowed: Bool { get }

    func startRecording(record: Record, completion: @escaping (Result<Record, RecordServiceError>) -> Void)
    func stopRecording(completion: @escaping (Result<Record, RecordServiceError>) -> Void)
}


//MARK: - Error

enum RecordServiceError: Error {
    case recordPermissionIsNotAllowed
    case recordgingIsNotStarted
    case recordgingIsNotStopped
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    var isAudioRecordingAllowed = false
    
    private var record: Record?
    
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder = AVAudioRecorder()
    private let fileManagerInstance = FileManager.default

    
    private let storedInFolderWithName = "WRRecords"
    private let storeWithFormatName = "m4a"
    
    
    
    init() {
        setupAudioRecorder()
        prepareFolderForStoreOnDevice(withName: storedInFolderWithName)
    }
    
    private func setupAudioRecorder() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            AVAudioApplication.requestRecordPermission() { allowed in
                DispatchQueue.main.async { [weak self] in
                    if !allowed {
                        print("ERROR: Audio permission is not allowed!")
                        self?.isAudioRecordingAllowed = false
                    } else {
                        print("SUCCESS: Audio permission allowed!")
                        self?.isAudioRecordingAllowed = true
                        self?.audioRecorder.isMeteringEnabled = true
                        self?.audioRecorder.prepareToRecord()
                    }
                }
            }
        } catch {
            print("ERROR: Cant setup audio recorder. \(error)")
        }
    }
}

//MARK: - Private

private extension RecordService {
    
    func prepareFolderForStoreOnDevice(withName name: String) {
        let documentsFolder = fileManagerInstance.urls(for: .documentDirectory,in: .userDomainMask)[0]
        let storageFolderPath = documentsFolder.appendingPathComponent(name).path()
        
        if !fileManagerInstance.fileExists(atPath: storageFolderPath) {
                do {
                    try fileManagerInstance.createDirectory(atPath: storageFolderPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("ERROR: Cant create folder in Documents directory: \(error)")
                }
            }
    }

    func setupFilePathToSave(fileName fName: String) -> URL {
        fileManagerInstance.urls(for: .documentDirectory,in: .userDomainMask)[0]
            .appendingPathComponent(storedInFolderWithName)
            .appendingPathComponent(fName)
            .appendingPathExtension(storeWithFormatName)
        
    }
    
    func setSettings() -> [String: Int] {
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
   
    func startRecording(record: Record, completion: @escaping (Result<Record, RecordServiceError>) -> Void) {
        self.record = nil
        // Check permission avalible
        guard
            isAudioRecordingAllowed
        else {
            print("ERROR: Cant start recording because it is not allowed!")
            completion(.failure(.recordPermissionIsNotAllowed))
            return
        }
        
        // Create path to save file
        let audioPath = setupFilePathToSave(fileName: record.name)
        print("** Record will stored into: \(audioPath)")
        
        // Store record into variable
        record.format = storeWithFormatName
        self.record = record

        // Setup settings
        let settings = setSettings()
        
        // Process
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.recordingSession.setActive(true)
                self.audioRecorder = try AVAudioRecorder(url: audioPath, settings: settings)
                self.audioRecorder.record()
                
                // Check
                if self.audioRecorder.isRecording {
                    record.path = self.audioRecorder.url
                    completion(.success(record))
                    print(">>> RECORD STARTED!")
                } else {
                    completion(.failure(.recordgingIsNotStarted))
                    self.record = nil
                    print(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
                }
                
            } catch {
                self.stopRecording { [unowned self] _ in
                    self.record = nil
                    print("ERROR: Cannot activate recorder session. \(error) ")
                }
            }
        }
    }
    
    func stopRecording(completion: @escaping (Result<Record, RecordServiceError>) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            // Trying to stop
            self.audioRecorder.stop()
            try? self.recordingSession.setActive(false)

            // Check
            if !self.audioRecorder.isRecording,
               let record = self.record {

                // Finally set duration to record and send it out
                record.duration = audioRecorder.currentTime
                completion(.success(record))
                print(">>> RECORDING STOPPED!")

            } else {
                completion(.failure(.recordgingIsNotStopped))
                self.record = nil
                print(">>> RECORDING IS NOT STOPPED! SOMETHING WRONG")
            }
        }
    }
}
