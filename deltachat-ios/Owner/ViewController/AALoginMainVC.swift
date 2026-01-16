//
//  AALoginMainVC.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/16.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import UIKit
import SnapKit
import DcCore
import IQKeyboardManagerSwift

class AALoginMainVC: UIViewController {

    
    var dcContext: DcContext
    
    var dcAccounts: DcAccounts
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 顶部背景与插图
    private let topBackground = UIImageView(image: UIImage(named: "Login_Top_bg"))
    private let logoImageView = UIImageView(image: UIImage(named: "Login_Top_icon"))
    
    // 输入框与按钮
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill

        return sv
    }()
    
    private let accountField = createCustomTextField(icon: "person.fill", placeholder: "账号")
    private let passwordField = createCustomTextField(icon: "lock.fill", placeholder: "密码", isSecure: true)
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor.systemOrange
        btn.layer.cornerRadius = 28
        // 添加点击缩放动画效果
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()

    private let registerLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            
        // --- 1. 设置行间距 (Line Spacing) ---
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10 // 在这里调整行间距数值，越大距离越远
            paragraphStyle.alignment = .center // 保持居中
        
            // 设置富文本：灰色文字 + 蓝色链接
            let fullText = "您还没有账号，快去注册吧？\n创建新账号"
            let attributedString = NSMutableAttributedString(string: fullText)
            let range1 = (fullText as NSString).range(of: "您还没有账号，快去注册吧？")
            let range2 = (fullText as NSString).range(of: "创建新账号")
            
        // 应用到全文范围
            let fullRange = NSRange(location: 0, length: fullText.count)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray, range: range1)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: range1)
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range2)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: range2)
            
            label.attributedText = attributedString
            return label
        }()
    
    
    init(dcContext: DcContext,dcAccounts:DcAccounts) {
        self.dcContext = dcContext
        self.dcAccounts = dcAccounts
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
        setupTapToDismiss()
        setupRegisterTap()
        IQKeyboardManager.shared.keyboardDistance = 50;
        IQKeyboardManager.shared.isEnabled = true;
        
        (accountField.viewWithTag(100) as? UITextField)?.text = "plm@aa1234.com"
        (passwordField.viewWithTag(100) as? UITextField)?.text = "plm"

    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false;

    }

    // MARK: - 交互逻辑 (Interaction)
    @objc private func handleLogin() {
        // 获取输入内容 (示例)
        guard let email = (accountField.viewWithTag(100) as? UITextField)?.text,
              let password = (passwordField.viewWithTag(100) as? UITextField)?.text else { return }
        
       
        
        if email.isEmpty == true {
            ProgressHUD.failed("请输入邮箱")
            return
        }
        
        if password.isEmpty == true {
            ProgressHUD.failed("请输入密码")
            return
        }
        
        if email.isValidEmail == false {
            ProgressHUD.failed("请输入正确的邮箱")
            return
        }
        
        
        let keyInputVC = SecretKeyViewController(mail: email, password: password, nickName: "", dcContext: self.dcContext, dcAccounts: self.dcAccounts)
        self.navigationController?.pushViewController(keyInputVC, animated: true)
        

    }





 

    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    // MARK: - UI & Layout
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 模拟原图顶部的黄色弧形背景
//        topBackground.backgroundColor = .systemYellow
//        topBackground.layer.cornerRadius = 50
//        topBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        contentView.addSubview(topBackground)
        contentView.addSubview(logoImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(accountField)
        stackView.addArrangedSubview(passwordField)
        contentView.addSubview(loginButton)
        view.addSubview(registerLabel) // 确保这行存在！
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            
        }
        
        topBackground.snp.makeConstraints { make in
            let size = UIScreen.main.bounds.width
            make.top.left.right.equalToSuperview()
            make.height.equalTo(size) // 增加高度，确保有足够的空间
        }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.centerY.equalTo(topBackground.snp.bottom).offset(-40)
            make.centerY.equalTo(topBackground.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(200)
        }
        
        // --- 重点：StackView 内部子视图约束 ---
        stackView.snp.makeConstraints { make in
            make.top.equalTo(topBackground.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(35)
        }
        
        // 显式设置输入框高度（这里是关键）
        [accountField, passwordField].forEach { field in
            field.snp.makeConstraints { make in
                make.height.equalTo(56) // 对应原图中圆润且厚实的高度
            }
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(35)
            make.left.right.equalTo(stackView)
            make.height.equalTo(56) // 保持一致
            make.bottom.equalToSuperview().offset(-60) // 确保 contentSize 能够撑开
        }
        
        // MARK: - 底部文字布局调整
            registerLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                // 1. 核心：相对于父容器底部（考虑到安全区域）
                make.bottom.equalToSuperview().offset(-40)
                // 2. 核心：相对于登录按钮的最小距离（防止重叠）
//                make.top.greaterThanOrEqualTo(loginButton.snp.bottom).offset(40)
            }
    }
    
    
    // 1. 在类定义中增加手势识别
    private func setupRegisterTap() {
        registerLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRegisterTap))
        registerLabel.addGestureRecognizer(tap)
    }

    @objc private func handleRegisterTap(gesture: UITapGestureRecognizer) {
        let text = registerLabel.text ?? ""
        let signupRange = (text as NSString).range(of: "创建新账号")
        
        // 检查点击位置是否在蓝色文字范围内
        if gesture.didTapAttributedTextInLabel(label: registerLabel, inRange: signupRange) {
            print("跳转到注册页面...")
            // 这里执行具体的跳转逻辑，例如：
            // let vc = RegisterViewController()
            // navigationController?.pushViewController(vc, animated: true)
            let registerVC = RegisterMailViewController(dcAccounts: self.dcAccounts)
            self.navigationController?.pushViewController(registerVC, animated: true)
            
           
        }
    }
    
    // 静态工厂方法：创建带图标的输入框容器
    private static func createCustomTextField(icon: String, placeholder: String, isSecure: Bool = false) -> UIView {
        let container = UIView()
        container.backgroundColor = .white // 纯白背景配合轻微阴影效果最好
            container.layer.cornerRadius = 28
            
            // --- 关键：更细腻的阴影设置 ---
            container.layer.shadowColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
            container.layer.shadowOpacity = 0.3  // 透明度
            container.layer.shadowOffset = CGSize(width: 0, height: 4) // 向下偏移
            container.layer.shadowRadius = 8     // 模糊半径
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = .systemGray3
        
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.isSecureTextEntry = isSecure
        tf.tag = 100 // 设置 tag 方便获取内容
        
        container.addSubview(iv)
        container.addSubview(tf)
        
        iv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        tf.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(12)
            make.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
//            make.height.equalTo(56)
        }
        
        return container
    }
}
