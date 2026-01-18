import UIKit
import SnapKit
import DcCore

class SecretKeyViewController: AABaseViewController {

    
    let mail:String
    let password:String
    
    var loginParam:DcEnteredLoginParam?

     var dcContext: DcContext
     let dcAccounts: DcAccounts
    
    var loginTool:AALoginAccountTool?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 顶部 1:1 圆形背景与渐变
    private let topBackground = UIImageView(image: UIImage(named: "Login_Top_bg"))
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        return btn
    }()
    
    private let illustrationImageView = UIImageView(image: UIImage(named: "key_Top_icon"))
    
    // 秘钥输入卡片
    private let inputCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
//        view.clipsToBounds = true
        return view
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
//        tv.text = "请输入您的秘钥"
        tv.textColor = .lightGray
        // 精确控制文字边距
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 设置行间距
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 6
            tv.typingAttributes = [.paragraphStyle: style, .font: UIFont.systemFont(ofSize: 16)]
        
        return tv
    }()
    
    private let pasteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("粘贴秘钥", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        btn.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return btn
    }()
    
    private let mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    private let resetKeyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("重置秘钥", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray5.cgColor
        btn.layer.cornerRadius = 28
        return btn
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 28
        return btn
    }()

    
    // 模拟 Placeholder
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入您的秘钥"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    
    init(mail: String, password: String,nickName:String,dcContext:DcContext,dcAccounts:DcAccounts) {
        self.mail = mail
        self.password = password
        self.dcContext = dcContext
        self.dcAccounts = dcAccounts
//        self.nickName = nickName;
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupInteractions()
        self.loginTool = AALoginAccountTool(dcAccounts: self.dcAccounts, currentVC: self)
        self.resetKeyButton.addTarget(self, action: #selector(showResetAlert), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.contentInsetAdjustmentBehavior = .never

        
        contentView.addSubview(topBackground)
//        contentView.addSubview(backButton)
        contentView.addSubview(illustrationImageView)
        contentView.addSubview(inputCardView)
        
        inputCardView.addSubview(textView)
        inputCardView.addSubview(placeholderLabel)

        inputCardView.addSubview(pasteButton)
        
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(resetKeyButton)
        mainStackView.addArrangedSubview(loginButton)
        

        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
    }
    
    

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
//            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide)
        }
        
        // 1:1 圆形背景布局
        let bgSize = UIScreen.main.bounds.width 
        topBackground.snp.makeConstraints { make in
            make.width.height.equalTo(bgSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
//        backButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(-40)
//            make.left.equalToSuperview().offset(15)
//            make.size.equalTo(40)
//        }
        
        illustrationImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topBackground.snp.top).offset(56)
            make.width.equalTo(240)
            make.height.equalTo(200)
        }
        
        inputCardView.snp.makeConstraints { make in
            make.top.equalTo(illustrationImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(200)
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        pasteButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(15)
            make.height.equalTo(32)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(inputCardView.snp.bottom).offset(40)
            make.left.right.equalTo(inputCardView)
            make.bottom.equalToSuperview().offset(-40) // 确保底部留白
        }
        
        [resetKeyButton, loginButton].forEach { $0.snp.makeConstraints { $0.height.equalTo(56) } }
    }

    // MARK: - Interactions
    private func setupInteractions() {
        textView.delegate = self
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        pasteButton.addTarget(self, action: #selector(handlePaste), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleBack() { navigationController?.popViewController(animated: true) }
    
    @objc private func handlePaste() {
        if let str = UIPasteboard.general.string {
            textView.text = str
            textView.textColor = .black
            self.textViewDidChange(self.textView)
        }
    }

    @objc private func loginAction() {
        
        if self.textView.text?.isEmpty == true || self.textView.text.count == 0 {
            ProgressHUD.failed("请输入密钥")
            return
        }
        
        self.dcAccounts.stopIo()

        self.loginTool?.login(name: "", email: self.mail, password: self.password, key:  self.textView.text ?? "")
    }
    
    // MARK: - Logic Actions
        @objc private func showResetAlert() {
            
            let alertVC = ResetKeyAlertViewController()
             
                self.present(alertVC, animated: true)
            
            alertVC.resetAction = {[weak self] in
                guard let self = self else { return  }
                self.textView.text =  self.dcContext.createKeypair(email: self.mail)
                self.textViewDidChange(self.textView)
            }

        }
    

}

extension SecretKeyViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        }else{
            placeholderLabel.isHidden = true

        }
    }
    
    // MARK: - Actions & Delegates
    func textViewDidChange(_ textView: UITextView) {
        // 控制 Placeholder 显示
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // 核心：强制 StackView 重新布局以响应 TextView 高度变化
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
