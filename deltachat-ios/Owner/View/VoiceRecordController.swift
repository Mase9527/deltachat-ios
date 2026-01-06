import UIKit
import AVFoundation

protocol VoiceRecordControllerDelegate: AnyObject {
    func voiceRecordControllerDidFinish(url: URL, duration: TimeInterval)
    func voiceRecordControllerDidFail(error: Error)
}

class VoiceRecordController: NSObject {

    weak var delegate: VoiceRecordControllerDelegate?

    private let button: UIButton
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingDuration: TimeInterval = 0
    private var hud: VoiceRecordHUD?

    private let maxDuration: TimeInterval
    private let countdownDuration: TimeInterval = 10.0
    private let minDuration: TimeInterval = 1.0

    private var isCancelled = false
    private var isRecording = false

    init(button: UIButton, maxDuration: TimeInterval = 60.0) {
        self.button = button
        self.maxDuration = maxDuration
        super.init()
        setupButtonActions()
    }

    private func setupButtonActions() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.1
        button.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: button)
        let isInside = button.bounds.contains(point)

        switch gesture.state {
        case .began:
            startRecording()
        case .changed:
            if isRecording {
                updateHUDState(isInside: isInside)
            }
        case .ended, .cancelled, .failed:
            stopRecording(isCancelled: !isInside)
        default:
            break
        }
    }

    private func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self, granted else {
                // Handle permission denial on the main thread
                DispatchQueue.main.async {
                    self?.delegate?.voiceRecordControllerDidFail(error: NSError(domain: "VoiceRecordController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Microphone permission denied."]))
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isRecording = true
                self.isCancelled = false
                self.setupRecorder()
                self.audioRecorder?.record()
                self.showHUD()
                self.startTimer()
                self.button.setTitle("松开 结束", for: .normal)
            }
        }
    }

    private func stopRecording(isCancelled: Bool) {
        guard isRecording else { return }
        isRecording = false

        let duration = audioRecorder?.currentTime ?? 0
        let url = audioRecorder?.url
        
        audioRecorder?.stop()
        stopTimer()

        if isCancelled || duration < minDuration {
            if duration < minDuration && !isCancelled {
                hud?.update(for: .tooShort)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.dismissHUD()
                }
            } else {
                dismissHUD()
            }
            audioRecorder?.deleteRecording()
        } else if let url = url {
            dismissHUD()
            delegate?.voiceRecordControllerDidFinish(url: url, duration: duration)
        }
        
        audioRecorder = nil
        button.setTitle("按住 说话", for: .normal)
    }

    private func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .duckOthers)
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("voiceRecord-\(Date().timeIntervalSince1970).m4a")
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
        } catch {
            delegate?.voiceRecordControllerDidFail(error: error)
        }
    }

    private func showHUD() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        let hud = VoiceRecordHUD()
        self.hud = hud
        window.addSubview(hud)
        hud.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hud.update(for: .recording)
    }

    private func dismissHUD() {
        hud?.removeFromSuperview()
        hud = nil
    }

    private func updateHUDState(isInside: Bool) {
        if isInside {
            hud?.update(for: .recording)
        } else {
            hud?.update(for: .releaseToCancel)
        }
    }

    private func startTimer() {
        recordingDuration = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateMeters), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateMeters() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }

        recordingDuration += 0.1

        if recordingDuration >= maxDuration {
            stopRecording(isCancelled: false)
            return
        }

        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        hud?.update(power: power)

        let remainingTime = maxDuration - recordingDuration
        if remainingTime <= countdownDuration {
            let countdownValue = Int(ceil(remainingTime))
            hud?.update(for: .countdown(countdownValue))
        }
    }
}

extension VoiceRecordController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(isCancelled: true)
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            delegate?.voiceRecordControllerDidFail(error: error)
        }
        stopRecording(isCancelled: true)
    }
}