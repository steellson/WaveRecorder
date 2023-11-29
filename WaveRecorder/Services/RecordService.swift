//
//  RecordService.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 29.11.2023.
//

import AVFoundation


//MARK: - Protocol

protocol RecordServiceProtocol: AnyObject {
//    var record:
    var delegate: AVAudioRecorderDelegate? { get set }
    var isAudioRecordingAllowed: Bool { get }

    func startRecord(withName name: String)
    func stopRecord(success: Bool)
}


//MARK: - Impl

final class RecordService: RecordServiceProtocol {
    
    weak var delegate: AVAudioRecorderDelegate?
    
    var isAudioRecordingAllowed = false
        
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder = AVAudioRecorder()
    
    init() {
        setupAudioRecorder()
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
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


//MARK: - Public

extension RecordService {
   
    func startRecord(withName name: String) {
        guard isAudioRecordingAllowed else {
            print("ERROR: Cant start recording because it is not allowed!")
            return
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(name).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            
            // Check
            audioRecorder.isRecording
            ? print(">>> RECORD STARTED!")
            : print(">>> RECORD IS NOT STARTERD! SOMETHING WRONG")
        } catch {
            stopRecord(success: false)
        }
    }
    
    func stopRecord(success: Bool) {
        audioRecorder.stop()
        try? recordingSession.setActive(false)

        // Check
        !audioRecorder.isRecording
        ? print(">>> RECORD STOPPED!")
        : print(">>> RECORD IS NOT STOPPED! SOMETHING WRONG")
    }
}
