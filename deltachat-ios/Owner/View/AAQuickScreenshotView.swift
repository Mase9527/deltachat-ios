import UIKit
import SnapKit

class AAQuickScreenshotView: UIView {
    
    var onImageSelected: ((UIImage) -> Void)?
    var onCloseTapped: (() -> Void)?
    
    private let containerStack = UIStackView()
    private let imageView = UIImageView()
    private let tipLabel = UILabel()
    private let closeButton = UIButton()
    private var currentImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        addShadow()
        
        // 1. 标题 (在上)
        tipLabel.text = "您可能要发送这张图"
        tipLabel.font = .systemFont(ofSize: 12, weight: .regular)
        tipLabel.textColor = .secondaryLabel
        addSubview(tipLabel)
        
        // 2. 图片 (在下)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.systemGray6
        addSubview(imageView)
        
        // 3. 关闭按钮 (右上角)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.preferredSymbolConfiguration = .init(pointSize: 10, weight: .bold)
        closeButton.tintColor = .systemGray2
        closeButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        addSubview(closeButton)
        
        // --- SnapKit 布局 ---
        
        tipLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-8)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            // 根据截图比例，可以设置一个固定的宽高比或高度
            make.height.equalTo(imageView.snp.width).multipliedBy(1.5)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(20)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }

    private func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 12
    }

    func configure(with image: UIImage) {
        self.currentImage = image
        self.imageView.image = image
    }

    @objc private func handleTap() {
        if let img = currentImage { onImageSelected?(img) }
    }

    @objc private func handleClose() {
        onCloseTapped?()
    }
}
