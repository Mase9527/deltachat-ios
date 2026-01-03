import UIKit
import SnapKit
import DcCore

typealias AAPublicKeyCopySucessAction = ()->()
class AAPublicKeyPopupViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var publicKey: String
    
    var copySucessAction:AAPublicKeyCopySucessAction?

    // 1. 容器视图
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "公钥详情"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        return button
    }()

    // 2. 公钥文本框（加个灰色背景好看一点）
    private let keyBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()

    private let keyLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.lineBreakMode = .byCharWrapping // 确保长字符强制换行
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("复制公钥", for: .normal)
        button.backgroundColor = DcColors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    init(key:String) {
        self.publicKey = key;

        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(keyBackgroundView)
        keyBackgroundView.addSubview(keyLabel)
        contentView.addSubview(copyButton)

        keyLabel.text = publicKey
        keyLabel.numberOfLines = 20;
        keyLabel.lineBreakMode = .byTruncatingMiddle;
        // --- 优先级设置 (防止标题被拉伸的核心) ---
        // 强制标题保持自身内容高度，不被拉伸
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // 强制按钮保持高度，不被拉伸
        copyButton.setContentHuggingPriority(.required, for: .vertical)

        // --- SnapKit 布局 ---

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(closeButton.snp.left).offset(-10)
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().inset(20)
            make.size.equalTo(30)
        }

        keyBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24)
        }

        keyLabel.snp.makeConstraints { make in
            // 这里的 inset 决定了文字距离灰色背景边缘的距离
            make.edges.equalToSuperview().inset(15)
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(keyBackgroundView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24) // 关键：撑开 contentView 的底部
        }
        closeButton.isHidden = true;
        closeButton.addTarget(self, action: #selector(dismissMe), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 关键：计算当前内容所需的最小尺寸，并更新 preferredContentSize
        let targetSize = CGSize(width: UIScreen.main.bounds.width - 60, height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        if size.height != preferredContentSize.height {
            preferredContentSize = size
        }
    }

    @objc func copyAction() {
        UIPasteboard.general.string = publicKey
        copySucessAction?()
        dismiss(animated: true)
    }

    @objc func dismissMe() { dismiss(animated: true) }

    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AACenterPopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
