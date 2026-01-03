import UIKit
import SnapKit
import DcCore


class AALoginViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let mail:String
    let password:String
    var progressAlertHandler: ProgressAlertHandler?

    var loginParam:DcEnteredLoginParam?

     var dcContext: DcContext
     let dcAccounts: DcAccounts
    
    var nickName:String
    
    var loginTool:AALoginAccountTool?
    // 1. 新增顶部 Logo
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        // 这里可以使用本地图片: UIImage(named: "your_logo")
        iv.image = UIImage(named: "dc_logo")
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "账户登录"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textAlignment = .center // 居中显示更协调
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "请填写以下信息以验证您的身份"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private let emailInput = ModernInputView(title: "电子邮箱", icon: "envelope.fill", placeholder: "example@mail.com")
    private let passwordInput = ModernInputView(title: "安全密码", icon: "lock.fill", placeholder: "请输入密码", isSecure: false)
    
    var isLogin:Bool = false
    
    private let publicKeyTitle: UILabel = {
        let label = UILabel()
        label.text = "公钥 (Public Key)"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let publicKeyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 12
        tv.clipsToBounds = true
        tv.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        tv.isScrollEnabled = false
//        tv.placeholder = "请输入公钥"
        return tv
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("登 录", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = DcColors.primary
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.systemBlue.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowRadius = 12

        return btn
    }()
    
    private let resetKeyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("重新生成Key", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
//        btn.backgroundColor = .systemRed
        btn.setTitleColor(.systemRed, for: .normal)
//        btn.layer.cornerRadius = 16
//        btn.layer.shadowColor = UIColor.systemBlue.cgColor
//        btn.layer.shadowOpacity = 0.3
//        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
//        btn.layer.shadowRadius = 12

        return btn
    }()
    
    init(mail: String, password: String,nickName:String,dcContext:DcContext,dcAccounts:DcAccounts) {
        self.mail = mail
        self.password = password
        self.dcContext = dcContext
        self.dcAccounts = dcAccounts
        self.nickName = nickName;
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupUI()
        setupKeyboardNotifications()
        self.loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

        self.resetKeyButton.addTarget(self, action: #selector(resetKeyAction), for: .touchUpInside)

        
        self.passwordInput.textField.text = self.password;
        self.emailInput.textField.text = self.mail;
        
        self.loginTool = AALoginAccountTool(dcAccounts: self.dcAccounts, currentVC: self)
    }
    
    private func setupTheme() {
        view.backgroundColor = DcColors.defaultBackgroundColor
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 2. 将 logoImageView 放入 StackView 的第一项
        let stackView = UIStackView(arrangedSubviews: [
            logoImageView, titleLabel, subtitleLabel, emailInput, passwordInput, publicKeyTitle, publicKeyTextView, loginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        // 3. 自定义间距让布局更美观
        stackView.setCustomSpacing(20, after: logoImageView) // Logo 下方间距
        stackView.setCustomSpacing(8, after: titleLabel)     // 标题和副标题靠拢
        stackView.setCustomSpacing(30, after: subtitleLabel) // 副标题与表单间距
        stackView.setCustomSpacing(10, after: publicKeyTitle)
        
        contentView.addSubview(stackView)
        
        contentView.addSubview(self.resetKeyButton)
        
        if self.isLogin == true {
            self.resetKeyButton.isHidden = false;
        }else{
            self.resetKeyButton.isHidden = true;
        }
        resetKeyButton.sizeToFit()
        resetKeyButton.snp.makeConstraints { make in
            make.trailing.equalTo(passwordInput)
            make.centerY.equalTo(publicKeyTitle)
            
        }
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // 4. Logo 尺寸约束
        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(80) // 设置 Logo 高度
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40) // 顶部留白
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        publicKeyTextView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(100) }
        loginButton.snp.makeConstraints { $0.height.equalTo(56) }
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    // 键盘逻辑保持不变
    @objc private func handleKeyboard(notification: Notification) {
        guard let info = notification.userInfo, let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let height = frame.cgRectValue.height
        let insets = isShowing ? UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0) : .zero
        scrollView.contentInset = insets
        
        if isShowing {
            if let activeView = findFirstResponder(in: contentView) {
                let rect = activeView.convert(activeView.bounds, to: scrollView)
                scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -60), animated: true)
            }
        }
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for sub in view.subviews { if let found = findFirstResponder(in: sub) { return found } }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.loginTool?.uninit()
    }

    @objc func resetKeyAction() {
        
        if self.emailInput.textField.text?.isEmpty == true {
            ProgressHUD.failed("请输入邮箱")
            return
        }
        self.publicKeyTextView.text =  self.dcContext.createKeypair(email: self.emailInput.textField.text ?? "")
    }
    
    @objc func loginAction() {
       
        self.dcAccounts.stopIo()

        /// 导入私钥
//        let keyName = "ID:\(dcContext.id)->testKey.asc"
//        DocumentManager.createTextFile(named: keyName, content: self.publicKeyTextView.text)
//        let path = DocumentManager.getDocumentDirectoryString()+"/"+keyName
//        self.dcContext.imex(what: DC_IMEX_IMPORT_SELF_KEYS, directory: path)
//        let loginParam = DcEnteredLoginParam(addr: self.mail, password: password)
//        
//        self.loginParam = loginParam;
//        
//        self.dcAccounts.startIo()
//        
//        do {
//            
//            guard let loginParam = self.loginParam else { return  }
//            
//            _ = try self.dcContext.addOrUpdateTransport(param: loginParam)
//            
//        } catch {
//            DispatchQueue.main.async {
//                logger.error(error.localizedDescription)
//            }
//        }
        
        self.loginTool?.login(name: self.nickName, email: self.emailInput.textField.text ?? "", password: self.passwordInput.textField.text ?? "", key:  self.publicKeyTextView.text ?? "")
    }

    deinit {
        print("界面销毁了吗AALoinig")
    }
}

// ModernInputView 保持不变...
// MARK: - 自定义带标题和图标的输入框组件
class ModernInputView: UIView {
    private let label = UILabel()
     let textField = UITextField()
    private let bgView = UIView()
    private let iconView = UIImageView()

    init(title: String, icon: String, placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 12
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.font = .systemFont(ofSize: 16)
        
        addSubview(label)
        addSubview(bgView)
        bgView.addSubview(iconView)
        bgView.addSubview(textField)
        
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        bgView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview()
        }
    }
    
    
    
    
    override var isFirstResponder: Bool { textField.isFirstResponder }
    required init?(coder: NSCoder) { fatalError() }
}
