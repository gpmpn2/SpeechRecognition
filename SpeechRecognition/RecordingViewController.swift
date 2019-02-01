//
//  RecordingViewController.swift
//  SpeechRecognition
//
//  Created by Grant Maloney on 1/31/19.
//  Copyright © 2019 Grant Maloney. All rights reserved.
//

import UIKit
import Speech

class RecordingViewController: UIViewController {

    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording: Bool = false
    
    @IBOutlet weak var recordingHeader: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func handleRecordAction(_ sender: Any) {
        requestSpeechRecognition()
    }
    
    func requestSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization {
            [unowned self] (authStatus) in
            switch authStatus {
            case .authorized:
                do {
                    if !self.isRecording {
                        try self.startRecording()
                        self.isRecording = true
                        DispatchQueue.main.async {
                            self.recordButton.setImage(UIImage.init(named: "MicrophoneOff"), for: .normal)
                            self.recordingHeader.text = "Listening..."
                        }
                    } else {
                        self.stopRecording()
                        self.isRecording = false
                        DispatchQueue.main.async {
                            self.recordButton.setImage(UIImage.init(named: "Microphone"), for: .normal)
                            self.recordingHeader.text = "Press below to begin translating text to speech in real-time!"
                        }
                    }
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Not available on this device")
            case .notDetermined:
                print("Not determined")
            }
        }
    }
    
    @IBOutlet weak var recordingTextViewOutput: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.recordButton.setImage(UIImage.init(named: "Microphone"), for: .normal)
        }
        self.recordingTextViewOutput.isEditable = false

        // Do any additional setup after loading the view.
    }
}

extension RecordingViewController {
    fileprivate func startRecording() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let request = self.request else { return }
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if result != nil {
                if let transcription = result?.bestTranscription {
                    self.recordingTextViewOutput.text = transcription.formattedString
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
    
    fileprivate func stopRecording() {
        if audioEngine.isRunning {
            if let request = request {
                request.endAudio()
                self.request = nil
            }
            audioEngine.inputNode.reset()
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
}
