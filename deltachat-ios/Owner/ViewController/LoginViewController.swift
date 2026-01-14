//
//  LoginViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/14.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import DcCore
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {

    
    var dcContext: DcContext
    
    var dcAccounts: DcAccounts

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "dc_logo") // 请确保图片资源已添加
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear // 模拟图中的橙色背景
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    private let accountTextField = UITextField.createCustomTextField(placeholder: "账号/密码")
    private let passwordTextField = UITextField.createCustomTextField(placeholder: "密码", isSecure: true)
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemOrange
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let createAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("创建新账号", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        // 添加阴影或边框以匹配视觉
        btn.layer.borderWidth = 0.5
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)

        btn.layer.borderColor = UIColor.lightGray.cgColor
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [logoImageView, accountTextField, passwordTextField, loginButton, createAccountButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    init(dcContext: DcContext,dcAccounts:DcAccounts) {
        self.dcContext = dcContext
        self.dcAccounts = dcAccounts
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        self.createAccountButton.addTarget(self, action: #selector(createNewAccount), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        // 点击空白收起键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        IQKeyboardManager.shared.keyboardDistance = 50;
        IQKeyboardManager.shared.isEnabled = true;

    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false;

    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 245/255, alpha: 1.0) // 浅米色背景
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // 设置 StackView 中元素的特定间距
        stackView.setCustomSpacing(60, after: logoImageView)
        stackView.setCustomSpacing(40, after: passwordTextField)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview() // 锁定水平滚动
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(120).priority(.high)
            make.centerX.equalToSuperview()
        }
        
        // 设置所有输入框和按钮的统一高度
        [accountTextField, passwordTextField, loginButton, createAccountButton].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(55)
            }
        }
    }
    
    @objc func loginAction(){
        
        let email = self.accountTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
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
        
        
        let keyInputVC = KeyInputViewController(mail: email, password: password, nickName: "", dcContext: self.dcContext, dcAccounts: self.dcAccounts)
        self.navigationController?.pushViewController(keyInputVC, animated: true)
    }
    
    @objc func createNewAccount(){
        
        let registerVC = RegisterMailViewController(dcAccounts: self.dcAccounts)
        self.navigationController?.pushViewController(registerVC, animated: true)

    }
    
}

// MARK: - Helper Extension
extension UITextField {
    static func createCustomTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.isSecureTextEntry = isSecure
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.textAlignment = .center
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        return tf
    }
}
