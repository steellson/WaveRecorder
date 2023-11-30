//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import AVFoundation


//MARK: - Protocol

protocol RecordServiceProtocol: AnyObject {
    var delegate: AVAudioRecorderDelegate? { get set }
    var isAudioRecordingAllowed: Bool { get }

    func startRecord(withName name: String)
    func stopRecord(withName name: String, completion: ((Record?) -> Void)?)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    weak var delegate: AVAudioRecorderDelegate?
    
    var isAudioRecordingAllowed = false
        
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
                        guard let delegate = self?.delegate else { return }
                        self?.audioRecorder.delegate = delegate
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
}


//MARK: - Public

extension RecordService {
   
    func startRecord(withName name: String) {
        guard isAudioRecordingAllowed else {
            print("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        let audioPath = PathManager.instance.createNewFile(
            withDirectoryName: storedInFolderWithName,
            fileName: name,
            formatName: storeWithFormatName
        )
        print("** Record will be saved to: \(audioPath)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.recordingSession.setActive(true)
                self.audioRecorder = try AVAudioRecorder(url: audioPath, settings: settings)
                self.audioRecorder.record()
                
                // Check
                self.audioRecorder.isRecording
                ? print(">>> RECORD STARTED!")
                : print(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
            } catch {
                self.stopRecord(withName: name, completion: nil)
            }
        }
    }
    
    func stopRecord(withName name: String, completion: ((Record?) -> Void)?) {
        DispatchQueue.global().async { [unowned self] in
            self.audioRecorder.stop()
            try? self.recordingSession.setActive(false)

            // Check
            !self.audioRecorder.isRecording
            ? print(">>> RECORD STOPPED!")
            : print(">>> RECORD IS NOT STOPPED! SOMETHING WRONG")
     
            let outputPath = audioRecorder.url
            let track = AVPlayerItem(url: outputPath)
            
            let record = Record(
                name: name,
                path: outputPath.path(percentEncoded: true),
                duration: track.duration.seconds,
                date: .now
            )
            completion?(record)
        }
    }
}
