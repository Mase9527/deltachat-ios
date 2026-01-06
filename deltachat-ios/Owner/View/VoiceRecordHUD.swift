import UIKit
import SnapKit

class VoiceRecordHUD: UIView {

    enum State {
        case recording
        case releaseToCancel
        case countdown(Int)
        case tooShort
    }

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = .white
        imageView.contentMode = .center
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    private let volumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "voice_record_volume_1") // Placeholder
        imageView.tintColor = .white
        imageView.contentMode = .center
        return imageView
    }()
    
    private var volumeImages: [UIImage] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        preloadVolumeImages()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubview(iconImageView)
        backgroundView.addSubview(statusLabel)
        backgroundView.addSubview(volumeImageView)

        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 150))
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.top).offset(25)
            make.leading.equalTo(backgroundView.snp.leading).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(80)
        }
        
        volumeImageView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.top)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalTo(backgroundView.snp.trailing).offset(-20)
            make.bottom.equalTo(iconImageView.snp.bottom)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(backgroundView.snp.bottom).offset(-10)
        }
    }
    
    private func preloadVolumeImages() {
        // In a real app, you would have images named voice_record_volume_1, voice_record_volume_2, etc.
        // Here we'll generate them programmatically for demonstration.
        for i in 1...8 {
            if let image = createVolumeImage(level: i) {
                volumeImages.append(image)
            }
        }
    }

    func update(for state: State) {
        switch state {
        case .recording:
            iconImageView.image = UIImage(systemName: "mic.fill")
            statusLabel.text = "手指上滑，取消发送"
            statusLabel.backgroundColor = .clear
            statusLabel.layer.cornerRadius = 0
            volumeImageView.isHidden = false
            iconImageView.isHidden = false
        case .releaseToCancel:
            iconImageView.image = UIImage(systemName: "arrow.uturn.backward.circle")
            statusLabel.text = "松开手指，取消发送"
            statusLabel.backgroundColor = UIColor.red.withAlphaComponent(0.8)
            statusLabel.layer.cornerRadius = 4
            statusLabel.clipsToBounds = true
            volumeImageView.isHidden = true
            iconImageView.isHidden = false
        case .countdown(let seconds):
            statusLabel.text = "还能说 \(seconds) 秒"
            statusLabel.backgroundColor = .clear
            volumeImageView.isHidden = false
            iconImageView.isHidden = false
        case .tooShort:
            iconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
            statusLabel.text = "说话时间太短"
            statusLabel.backgroundColor = .clear
            volumeImageView.isHidden = true
            iconImageView.isHidden = false
        }
    }

    func update(power: Float) {
        // Normalize power to a level between 0 and 1
        let normalizedPower = max(0, 1 - (power / -60))
        
        // Map normalized power to an image index (0 to 7)
        let imageIndex = Int(normalizedPower * Float(volumeImages.count - 1))
        
        if imageIndex < volumeImages.count {
            volumeImageView.image = volumeImages[imageIndex]
        }
    }
    
    // Helper to create volume images dynamically
    private func createVolumeImage(level: Int) -> UIImage? {
        let barCount = 8
        let barWidth: CGFloat = 4
        let barMaxHeight: CGFloat = 60
        let spacing: CGFloat = 3
        let size = CGSize(width: 50, height: 80)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.white.cgColor)

        for i in 0..<barCount {
            let barHeight = (CGFloat(i) / CGFloat(barCount - 1)) * barMaxHeight
            let yPos = (size.height - barHeight) / 2
            
            if i < level {
                let rect = CGRect(x: CGFloat(i) * (barWidth + spacing), y: yPos, width: barWidth, height: barHeight)
                context.fill(rect)
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysTemplate)
    }
}