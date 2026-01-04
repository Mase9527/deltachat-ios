//
//  VoiceRecordView.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/4.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import CoreGraphics

// MARK: - 录音界面代理协议
protocol VoiceRecordViewDelegate: AnyObject {
    func voiceRecordViewDidStartRecording(_ view: VoiceRecordView)
    func voiceRecordViewDidFinishRecording(_ view: VoiceRecordView, audioData: Data, duration: TimeInterval)
    func voiceRecordViewDidCancelRecording(_ view: VoiceRecordView)
    func voiceRecordViewDidRequestPermission(_ view: VoiceRecordView, granted: Bool)
}

// MARK: - 主录音界面
class VoiceRecordView: UIView {
    
    // MARK: - 枚举定义
    enum RecordState {
        case idle          // 空闲状态
        case recording     // 录音中
        case cancelling    // 取消中（上滑取消）
        case tooShort      // 录音时间太短
    }
    
    enum AudioQuality {
        case low
        case medium
        case high
    }
    
    // MARK: - 属性
    weak var delegate: VoiceRecordViewDelegate?
    
    private var currentState: RecordState = .idle {
        didSet { updateUIForState() }
    }
    
    private var audioRecorder: AVAudioRecorder?
    private var audioMeterTimer: Timer?
    private var recordingStartTime: Date?
    private var audioLevels: [CGFloat] = []
    
    private let maxDuration: TimeInterval = 60 // 最大录音时长60秒
    private let minDuration: TimeInterval = 1  // 最小录音时长1秒
    private var currentDuration: TimeInterval = 0
    
    private var audioQuality: AudioQuality = .medium
    
    // MARK: - UI组件
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    private lazy var micIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "向上滑动取消"
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.text = "0:00"
        return label
    }()
    
    private lazy var cancelIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        imageView.tintColor = UIColor(hex: 0xF44336)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.text = "松开手指，取消发送"
        label.alpha = 0
        return label
    }()
    
    private lazy var waveformView: WaveformView = {
        let view = WaveformView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var recordingAnimationView: RecordingAnimationView = {
        let view = RecordingAnimationView()
        view.isHidden = true
        return view
    }()
    
    private lazy var tooShortView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        view.isHidden = true
        
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = UIColor(hex: 0xFF9800)
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "录音时间太短"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        
        view.addSubview(icon)
        view.addSubview(label)
        
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.width.height.equalTo(40)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    // 外部的触发按钮（可自定义）
    private weak var triggerButton: UIButton?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAudioSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupAudioSession()
    }
    
    deinit {
        stopMeterTimer()
    }
    
    // MARK: - 设置UI
    private func setupUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = false // 默认不交互，由外部按钮触发
        
        addSubview(backgroundView)
        addSubview(micIconView)
        addSubview(stateLabel)
        addSubview(timeLabel)
        addSubview(cancelIconView)
        addSubview(hintLabel)
        addSubview(waveformView)
        addSubview(recordingAnimationView)
        addSubview(tooShortView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(240)
        }
        
        micIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backgroundView).offset(40)
            make.width.height.equalTo(60)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(micIconView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        cancelIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(micIconView)
            make.width.height.equalTo(70)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelIconView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        waveformView.snp.makeConstraints { make in
            make.top.equalTo(micIconView.snp.bottom).offset(20)
            make.left.right.equalTo(backgroundView).inset(20)
            make.height.equalTo(60)
        }
        
        recordingAnimationView.snp.makeConstraints { make in
            make.center.equalTo(backgroundView)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        tooShortView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(120)
        }
    }
    
    // MARK: - 配置
    func configure(with triggerButton: UIButton) {
        self.triggerButton = triggerButton
        setupTriggerButton()
    }
    
    func setAudioQuality(_ quality: AudioQuality) {
        self.audioQuality = quality
    }
    
    private func setupTriggerButton() {
        triggerButton?.addTarget(self, action: #selector(triggerButtonTouchDown), for: .touchDown)
        triggerButton?.addTarget(self, action: #selector(triggerButtonTouchUpInside), for: .touchUpInside)
        triggerButton?.addTarget(self, action: #selector(triggerButtonTouchUpOutside), for: .touchUpOutside)
        triggerButton?.addTarget(self, action: #selector(triggerButtonDragInside), for: .touchDragInside)
        triggerButton?.addTarget(self, action: #selector(triggerButtonDragOutside), for: .touchDragOutside)
    }
    
    // MARK: - 状态管理
    private func updateUIForState() {
        switch currentState {
        case .idle:
            hideRecordingUI()
            tooShortView.isHidden = true
            recordingAnimationView.stopAnimating()
            
        case .recording:
            showRecordingUI()
            tooShortView.isHidden = true
            recordingAnimationView.isHidden = false
            recordingAnimationView.startAnimating()
            
            micIconView.alpha = 1
            cancelIconView.alpha = 0
            hintLabel.alpha = 0
            stateLabel.text = "向上滑动取消"
            waveformView.isHidden = false
            
        case .cancelling:
            micIconView.alpha = 0
            cancelIconView.alpha = 1
            hintLabel.alpha = 1
            stateLabel.text = "松开取消发送"
            waveformView.isHidden = true
            
        case .tooShort:
            hideRecordingUI()
            showTooShortWarning()
        }
    }
    
    private func showRecordingUI() {
        isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1
        })
    }
    
    private func hideRecordingUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
        }) { _ in
            self.isUserInteractionEnabled = false
            self.recordingAnimationView.isHidden = true
            self.waveformView.isHidden = true
        }
    }
    
    private func showTooShortWarning() {
        tooShortView.isHidden = false
        tooShortView.alpha = 0
        tooShortView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.tooShortView.alpha = 1
            self.tooShortView.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tooShortView.alpha = 0
                    self.tooShortView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }) { _ in
                    self.tooShortView.isHidden = true
                    self.currentState = .idle
                }
            }
        }
    }
    
    // MARK: - 触发按钮事件处理
    @objc private func triggerButtonTouchDown() {
        requestRecordingPermission()
    }
    
    @objc private func triggerButtonTouchUpInside() {
        if currentState == .recording {
            finishRecording(send: true)
        } else if currentState == .cancelling {
            cancelRecording()
        }
    }
    
    @objc private func triggerButtonTouchUpOutside() {
        if currentState == .recording {
            finishRecording(send: true)
        } else if currentState == .cancelling {
            cancelRecording()
        }
    }
    
    @objc private func triggerButtonDragInside() {
        if currentState == .recording {
            currentState = .recording
        }
    }
    
    @objc private func triggerButtonDragOutside() {
        if currentState == .recording {
            currentState = .cancelling
        }
    }
    
    // MARK: - 录音控制
    private func requestRecordingPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.delegate?.voiceRecordViewDidRequestPermission(self!, granted: granted)
                
                if granted {
                    self?.startRecording()
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("设置音频会话失败: \(error)")
        }
    }
    
    private func startRecording() {
        guard let audioURL = getAudioFileURL() else { return }
        
        let settings: [String: Any]
        switch audioQuality {
        case .low:
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 8000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
                AVEncoderBitRateKey: 32000
            ]
        case .medium:
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 22050,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                AVEncoderBitRateKey: 64000
            ]
        case .high:
            settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
        }
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            currentState = .recording
            recordingStartTime = Date()
            audioLevels.removeAll()
            startMeterTimer()
            
            delegate?.voiceRecordViewDidStartRecording(self)
            
            // 震动反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } catch {
            print("开始录音失败: \(error)")
            currentState = .idle
        }
    }
    
    private func finishRecording(send: Bool) {
        guard currentState == .recording || currentState == .cancelling,
              let recorder = audioRecorder else { return }
        
        let duration = recorder.currentTime
        recorder.stop()
        
        stopMeterTimer()
        audioRecorder = nil
        
        currentDuration = duration
        
        if send && currentState == .recording {
            if duration < minDuration {
                currentState = .tooShort
                delegate?.voiceRecordViewDidCancelRecording(self)
            } else {
                if let audioData = try? Data(contentsOf: recorder.url) {
                    delegate?.voiceRecordViewDidFinishRecording(self, audioData: audioData, duration: duration)
                    // 成功震动
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                currentState = .idle
            }
        } else {
            cancelRecording()
        }
    }
    
    private func cancelRecording() {
        stopMeterTimer()
        
        if let recorder = audioRecorder {
            recorder.stop()
            try? FileManager.default.removeItem(at: recorder.url)
            audioRecorder = nil
        }
        
        currentState = .idle
        delegate?.voiceRecordViewDidCancelRecording(self)
        
        // 取消震动
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func getAudioFileURL() -> URL? {
        let fileName = "voice_message_\(Date().timeIntervalSince1970).m4a"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        return fileURL
    }
    
    private func startMeterTimer() {
        stopMeterTimer()
        audioMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateAudioMeter()
        }
    }
    
    private func stopMeterTimer() {
        audioMeterTimer?.invalidate()
        audioMeterTimer = nil
    }
    
    private func updateAudioMeter() {
        guard let recorder = audioRecorder else { return }
        
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        
        // 将分贝值转换为0-1的范围
        let normalizedPower = (power + 160) / 160
        let clampedPower = min(max(normalizedPower, 0.1), 1.0)
        
        audioLevels.append(CGFloat(clampedPower))
        
        // 限制波形图数据量
        if audioLevels.count > 200 {
            audioLevels.removeFirst()
        }
        
        waveformView.updateWithAudioLevel(CGFloat(clampedPower))
        
        // 更新录音时间
        if let startTime = recordingStartTime {
            let duration = Date().timeIntervalSince(startTime)
            updateRecordingTime(duration)
            
            // 检查是否超时
            if duration >= maxDuration {
                finishRecording(send: true)
            }
        }
    }
    
    private func updateRecordingTime(_ duration: TimeInterval) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        // 接近最大时长时改变颜色
        if duration >= maxDuration - 10 {
            timeLabel.textColor = UIColor(hex: 0xFF5252)
        } else if duration >= maxDuration - 20 {
            timeLabel.textColor = UIColor(hex: 0xFF9800)
        } else {
            timeLabel.textColor = .white
        }
    }
    
    // MARK: - 权限提示
    private func showPermissionAlert() {
        guard let viewController = findViewController() else { return }
        
        let alert = UIAlertController(
            title: "需要麦克风权限",
            message: "请在设置中允许访问麦克风，以便发送语音消息",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "设置", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    // MARK: - 公开方法
    func reset() {
        currentState = .idle
        stopMeterTimer()
        
        if let recorder = audioRecorder {
            recorder.stop()
            audioRecorder = nil
        }
    }
    
    func getCurrentDuration() -> TimeInterval {
        return currentDuration
    }
    
    func isRecording() -> Bool {
        return currentState == .recording
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceRecordView: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            currentState = .idle
            print("录音失败")
        }
    }
}

// MARK: - 自定义UI组件

// 1. 波形图视图
class WaveformView: UIView {
    
    private var audioLevels: [CGFloat] = []
    private let maxLevels = 100
    private var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLink()
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func updateWithAudioLevel(_ level: CGFloat) {
        audioLevels.append(level)
        if audioLevels.count > maxLevels {
            audioLevels.removeFirst()
        }
    }
    
    @objc private func updateDisplay() {
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空背景
        context.clear(rect)
        
        if audioLevels.isEmpty {
            drawGuideLines(in: rect, context: context)
            return
        }
        
        // 绘制波形
        let lineWidth: CGFloat = 2
        let spacing: CGFloat = 1
        let totalWidth = CGFloat(audioLevels.count) * (lineWidth + spacing)
        let startX = (rect.width - totalWidth) / 2
        
        for (index, level) in audioLevels.enumerated() {
            let x = startX + CGFloat(index) * (lineWidth + spacing)
            let maxHeight = rect.height
            let height = maxHeight * level
            
            let y = (maxHeight - height) / 2
            
            let lineRect = CGRect(x: x, y: y, width: lineWidth, height: height)
            
            // 创建渐变颜色
            let gradientStartColor = UIColor(hex: 0x4CAF50).cgColor
            let gradientEndColor = UIColor(hex: 0x8BC34A).cgColor
            
            let path = UIBezierPath(roundedRect: lineRect, cornerRadius: lineWidth / 2)
            context.saveGState()
            path.addClip()
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [gradientStartColor, gradientEndColor] as CFArray,
                locations: [0, 1]
            )!
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: x, y: y),
                end: CGPoint(x: x, y: y + height),
                options: []
            )
            
            context.restoreGState()
        }
        
        // 绘制中心线
        drawGuideLines(in: rect, context: context)
    }
    
    private func drawGuideLines(in rect: CGRect, context: CGContext) {
        // 绘制中心线
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(0.5)
        
        let centerY = rect.height / 2
        context.move(to: CGPoint(x: 0, y: centerY))
        context.addLine(to: CGPoint(x: rect.width, y: centerY))
        context.strokePath()
        
        // 绘制上下边界线
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.1).cgColor)
        
        let topY = rect.height * 0.25
        let bottomY = rect.height * 0.75
        
        context.move(to: CGPoint(x: 0, y: topY))
        context.addLine(to: CGPoint(x: rect.width, y: topY))
        context.strokePath()
        
        context.move(to: CGPoint(x: 0, y: bottomY))
        context.addLine(to: CGPoint(x: rect.width, y: bottomY))
        context.strokePath()
    }
    
    func clear() {
        audioLevels.removeAll()
        setNeedsDisplay()
    }
}

// 2. 录音动画视图
class RecordingAnimationView: UIView {
    
    private var animationLayers: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimationLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAnimationLayers()
    }
    
    private func setupAnimationLayers() {
        backgroundColor = .clear
        
        let colors: [UIColor] = [
            UIColor(hex: 0x4CAF50).withAlphaComponent(0.6),
            UIColor(hex: 0x2196F3).withAlphaComponent(0.6),
            UIColor(hex: 0xFF9800).withAlphaComponent(0.6),
            UIColor(hex: 0xF44336).withAlphaComponent(0.6)
        ]
        
        let sizes: [CGFloat] = [0.8, 1.0, 1.2, 1.4]
        let durations: [CFTimeInterval] = [1.5, 2.0, 2.5, 3.0]
        
        for i in 0..<4 {
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.path = UIBezierPath(ovalIn: bounds).cgPath
            layer.fillColor = colors[i].cgColor
            layer.opacity = 0
            self.layer.addSublayer(layer)
            animationLayers.append(layer)
            
            // 缩放动画
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = sizes[i]
            scaleAnimation.toValue = sizes[i] * 2
            scaleAnimation.duration = durations[i]
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            layer.add(scaleAnimation, forKey: "scale")
            
            // 透明度动画
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0.6
            opacityAnimation.toValue = 0
            opacityAnimation.duration = durations[i]
            opacityAnimation.repeatCount = .infinity
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            layer.add(opacityAnimation, forKey: "opacity")
        }
    }
    
    func startAnimating() {
        isHidden = false
        for layer in animationLayers {
            layer.isHidden = false
        }
    }
    
    func stopAnimating() {
        for layer in animationLayers {
            layer.removeAllAnimations()
            layer.isHidden = true
        }
    }
}

// 3. 录音按钮
class RecordButton: UIButton {
    
    enum ButtonState {
        case normal
        case recording
    }
    
    private var currentState: ButtonState = .normal {
        didSet { updateAppearance() }
    }
    
    private var pulseLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 40
        clipsToBounds = true
        updateAppearance()
    }
    
    private func updateAppearance() {
        switch currentState {
        case .normal:
            backgroundColor = UIColor(hex: 0x07C160)
            setTitle("按住 说话", for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            stopPulseAnimation()
            
        case .recording:
            backgroundColor = UIColor(hex: 0xC62828)
            setTitle("松开 结束", for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        stopPulseAnimation()
        
        pulseLayer = CAShapeLayer()
        pulseLayer?.frame = bounds
        pulseLayer?.path = UIBezierPath(ovalIn: bounds).cgPath
        pulseLayer?.fillColor = UIColor(hex: 0x07C160).withAlphaComponent(0.3).cgColor
        layer.insertSublayer(pulseLayer!, at: 0)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.5
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseLayer?.add(scaleAnimation, forKey: "pulse")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 1.0
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseLayer?.add(opacityAnimation, forKey: "opacity")
    }
    
    private func stopPulseAnimation() {
        pulseLayer?.removeAllAnimations()
        pulseLayer?.removeFromSuperlayer()
        pulseLayer = nil
    }
    
    func setState(_ state: ButtonState) {
        currentState = state
    }
}

// MARK: - 工具扩展
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}

// MARK: - 使用示例
class VoiceRecordViewController: UIViewController {
    
    private lazy var voiceRecordView: VoiceRecordView = {
        let view = VoiceRecordView()
        view.delegate = self
        return view
    }()
    
    private lazy var recordButton: RecordButton = {
        let button = RecordButton()
        return button
    }()
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "长按按钮开始录音，上滑取消"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "录音时长: 0秒"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加标题
        let titleLabel = UILabel()
        titleLabel.text = "微信录音界面"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .darkText
        titleLabel.textAlignment = .center
        
        // 添加描述
        let descriptionLabel = UILabel()
        descriptionLabel.text = "仿微信录音界面实现\n支持上滑取消、音量波形显示"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(recordButton)
        view.addSubview(instructionsLabel)
        view.addSubview(durationLabel)
        view.addSubview(voiceRecordView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
        
        recordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-100)
            make.width.height.equalTo(80)
        }
        
        instructionsLabel.snp.makeConstraints { make in
            make.top.equalTo(recordButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(instructionsLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        voiceRecordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 配置录音界面
        voiceRecordView.configure(with: recordButton)
    }
    
    private func showResultMessage(_ message: String) {
        let alert = UIAlertController(title: "录音结果", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - VoiceRecordViewDelegate 实现
extension VoiceRecordViewController: VoiceRecordViewDelegate {
    func voiceRecordViewDidStartRecording(_ view: VoiceRecordView) {
        recordButton.setState(.recording)
        durationLabel.isHidden = false
        instructionsLabel.text = "正在录音...上滑取消"
    }
    
    func voiceRecordViewDidFinishRecording(_ view: VoiceRecordView, audioData: Data, duration: TimeInterval) {
        recordButton.setState(.normal)
        instructionsLabel.text = "长按按钮开始录音，上滑取消"
        durationLabel.text = String(format: "录音时长: %.1f秒", duration)
        
        // 显示结果
        showResultMessage("录音完成\n时长: \(String(format: "%.1f", duration))秒\n大小: \(audioData.count)字节")
    }
    
    func voiceRecordViewDidCancelRecording(_ view: VoiceRecordView) {
        recordButton.setState(.normal)
        instructionsLabel.text = "长按按钮开始录音，上滑取消"
        
        // 显示取消提示
        let alert = UIAlertController(title: "已取消", message: "录音已取消", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func voiceRecordViewDidRequestPermission(_ view: VoiceRecordView, granted: Bool) {
        if !granted {
            let alert = UIAlertController(
                title: "麦克风权限",
                message: "需要麦克风权限才能录音",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "设置", style: .default) { _ in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            present(alert, animated: true)
        }
    }
}

