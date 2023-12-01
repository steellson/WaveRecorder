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

    func startRecording(completion: @escaping (Result<Record, RecordServiceError>) -> Void)
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
    
    private let storedInFolderWithName = "WRRecords"
    private let storeWithFormatName = "m4a"
    
    
    
    init() {
        setupAudioRecorder()
        prepareFolderForStoreOnDevice(withName: storedInFolderWithName)
    }
    
    private func setupAudioRecorder() {
        do {
            try recordingSession.setCategory(.record, mode: .default)
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
    
    private func prepareFolderForStoreOnDevice(withName name: String) {
        PathManager.instance.createFolder(withDirectoryName: name)
    }
    
#warning("need to check")
    private func setupStoredRecordName() -> String {
//        [0..<1000].map { num in
//            
//            let documentsPath = PathManager.instance.getDocumentsDirectory()
//            let name = "Record \(num)"
//            let finallyURL = documentsPath.appendingPathComponent(name).appendingPathExtension(storedInFolderWithName)
//            
//            if !FileManager.default.fileExists(atPath: finallyURL.path())   {
//                return name
//            }
//            
//        }.first ?? "Record"
        ""
    }
    
    private func createRecord() -> Record {
        let name = setupStoredRecordName()
        
        let record = Record(
            name: name,
            path: "",
            duration: 2,
            date: .now
        )
        self.record = record
        
        return record
    }
    
    private func setupFilePathToSave() -> URL {
        PathManager.instance.createNewFile(
            withDirectoryName: storedInFolderWithName,
            fileName: setupStoredRecordName(),
            formatName: storeWithFormatName
        )
    }
    
    private func setSettings() -> [String: Int] {
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
   
    func startRecording(completion: @escaping (Result<Record, RecordServiceError>) -> Void) {
        // Check permission avalible
        guard
            isAudioRecordingAllowed
        else {
            print("ERROR: Cant start recording because it is not allowed!")
            completion(.failure(.recordPermissionIsNotAllowed))
            return
        }
        
        // Create record
        let record = createRecord()
        
        // Create path to save file
        let audioPath = setupFilePathToSave()
        print("** Record will be saved to: \(audioPath)")
        
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
                    completion(.success(record))
                    print(">>> RECORD STARTED!")
                } else {
                    completion(.failure(.recordgingIsNotStarted))
                    print(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
                }
                
            } catch {
                self.stopRecording { _ in print(error) }
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
                completion(.success(record))
                print(">>> RECORDING STOPPED!")
            } else {
                completion(.failure(.recordgingIsNotStopped))
                print(">>> RECORDING IS NOT STOPPED! SOMETHING WRONG")
            }
        }
    }
}
