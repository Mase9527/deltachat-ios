//
//  CreateAccountViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import UIKit
import SnapKit
import IQKeyboardManagerSwift
import DcCore



class CreateAccountViewController: UIViewController {

    private var dcContext: DcContext
    private let dcAccounts: DcAccounts
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 顶部背景区域
    private let headerBackground: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Create_top_icon") )
        view.backgroundColor = .systemOrange // 实际开发建议使用渐变色 Layer
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "创建新账号"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "请继续完善信息"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()

    // 使用 UIStackView 管理所有的输入框容器
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("下一步", for: .normal)
        btn.backgroundColor = .orange
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 28
        return btn
    }()
    
    private let otherServerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("使用其他服务器", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()
    
    let accountInput = InputView(icon: "envelope", placeholder: "请输入账号", suffix: "@aa1234.com")
    let passwordInput = InputView(icon: "lock", placeholder: "请输入密码", isSecure: true)
    let confirmInput = InputView(icon: "lock", placeholder: "请再次输入密码", isSecure: true)

    
    init(dcAccounts: DcAccounts) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()

 

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        // 点击空白收起键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        IQKeyboardManager.shared.keyboardDistance = 50;
        IQKeyboardManager.shared.isEnabled = true;
        
        self.nextButton.addTarget(self, action: #selector(nextStepAction), for: .touchUpInside)
        self.otherServerButton.addTarget(self, action: #selector(showOtherOptions), for: .touchUpInside)
        
        
//        self.accountInput.textField.text = "pkdoskjki"
//        self.passwordInput.textField.text = "123"
//        self.confirmInput.textField.text = "123"
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        [headerBackground, titleLabel, subTitleLabel, stackView, nextButton].forEach {
            contentView.addSubview($0)
        }
        
    
        view.addSubview(self.otherServerButton)
//        // 添加模拟输入框
//        addInputField(icon: "envelope", placeholder: "请输入账号", suffix: "@aa1234.com")
//        addInputField(icon: "lock", placeholder: "请输入密码", isSecure: true)
//        addInputField(icon: "lock", placeholder: "请再次输入密码", isSecure: true)
    }
    
    private func setupConstraints() {
        // 1. ScrollView 填满全屏
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 2. ContentView 决定滚动范围
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // 锁定宽度，只允许纵向滚动
        }
        
        // 3. 顶部装饰背景
        headerBackground.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(270)
        }
        
        // 4. 标题文字
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(30)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
        }
        
        // 5. 输入框 StackView (利用负偏移量实现“悬浮”在背景上的效果)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerBackground.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        // 6. 按钮
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(stackView)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-40) // 非常关键：撑起 contentView 的底部
        }
        
        // 直接创建并加入 StackView
         
            
            [accountInput, passwordInput, confirmInput].forEach { input in
                stackView.addArrangedSubview(input)
                input.snp.makeConstraints { make in
                    make.height.equalTo(60)
                }
            }
        
        // 在 setupConstraints 中添加
        otherServerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            // 初始位置：距离安全区域底部 20
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: - Helper 封装输入框
    private func addInputField(icon: String, placeholder: String, suffix: String? = nil, isSecure: Bool = false) {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 28
        // 添加阴影
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 8
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        
        container.addSubview(iconImageView)
        container.addSubview(textField)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        // 如果有后缀文字 (如 @aa1234.com)
        if let suffix = suffix {
            let suffixLabel = UILabel()
            suffixLabel.text = suffix
            suffixLabel.font = .systemFont(ofSize: 16)
            container.addSubview(suffixLabel)
            suffixLabel.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-20)
                make.centerY.equalToSuperview()
            }
            textField.snp.remakeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(12)
                make.trailing.equalTo(suffixLabel.snp.leading).offset(-8)
                make.centerY.equalToSuperview()
            }
        }
        
        stackView.addArrangedSubview(container)
        container.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    
    // MARK: - 交互逻辑 (Interaction)
    @objc private func nextStepAction() {
        // 获取输入内容 (示例)
        guard var email = accountInput.textField.text,
              let password = passwordInput.textField.text,let againPassword = confirmInput.textField.text else { return }
        
         email = email + "@aa1234.com"
        
       
        
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
        
        if password != againPassword {
            ProgressHUD.failed("两次输入的密码不一致")
        }
        
    
        let bindEmailVC = BindEmailViewController(dcAccounts: self.dcAccounts,email: email,password: password)
        self.navigationController?.pushViewController(bindEmailVC, animated: true)

    }


    @objc private func showOtherOptions() {
        let alertController = UIAlertController(title: String.localized("instant_onboarding_show_more_instances"), message: nil, preferredStyle: .safeActionSheet)
        let otherServersAction = UIAlertAction(title: String.localized("instant_onboarding_other_server"), style: .default) { [weak self] _ in

//            self?.storeImageAndName()

            guard let url = URL(string: "https://chatmail.at/relays") else { return }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }

        let manualAccountSetup = UIAlertAction(title: String.localized("manual_account_setup_option"), style: .default) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let accountSetupController = EditTransportViewController(dcAccounts: self.dcAccounts)
                accountSetupController.onLoginSuccess = {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.reloadDcContext()
                    }
                }
                self.navigationController?.pushViewController(accountSetupController, animated: true)
            }
        }



        let cancelAction = UIAlertAction(title: String.localized("cancel"), style: .cancel)

//        alertController.addAction(otherServersAction)
        alertController.addAction(manualAccountSetup)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

}


import UIKit
import SnapKit

class InputView: UIView {
    
    // UI 元素
    private let iconImageView = UIImageView()
     let textField = UITextField()
    private let stackView = UIStackView()
    private lazy var eyeButton = UIButton(type: .custom)
    private let suffixLabel = UILabel()
    
    // 初始化参数
    init(icon: String, placeholder: String, isSecure: Bool = false, suffix: String? = nil) {
        super.init(frame: .zero)
        setupUI(icon: icon, placeholder: placeholder, isSecure: isSecure, suffix: suffix)
    }
    
    // 初始化参数
    init(image: String, placeholder: String, isSecure: Bool = false, suffix: String? = nil) {
        super.init(frame: .zero)
        setupUI(image: image, placeholder: placeholder, isSecure: isSecure, suffix: suffix)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI(icon: String, placeholder: String, isSecure: Bool, suffix: String?) {
        // 容器样式：圆角、背景色、阴影
        backgroundColor = .white
        layer.cornerRadius = 30
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        
        // 图标
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        
        // 输入框
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.font = .systemFont(ofSize: 16)
        
        addSubview(iconImageView)
        addSubview(textField)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        
        // 动态处理右侧组件（后缀或眼睛按钮）
        if isSecure {
            setupEyeButton()
        } else if let suffixText = suffix {
            setupSuffixLabel(text: suffixText)
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-25)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    private func setupUI(image: String, placeholder: String, isSecure: Bool, suffix: String?) {
        // 容器样式：圆角、背景色、阴影
        backgroundColor = .white
        layer.cornerRadius = 30
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        
        // 图标
        iconImageView.image = UIImage(named: image)
//        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        
        // 输入框
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.font = .systemFont(ofSize: 16)
        
        addSubview(iconImageView)
        addSubview(textField)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        
        // 动态处理右侧组件（后缀或眼睛按钮）
        if isSecure {
            setupEyeButton()
        } else if let suffixText = suffix {
            setupSuffixLabel(text: suffixText)
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-25)
                make.centerY.equalToSuperview()
            }
        }
    }

    
    private func setupEyeButton() {
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .selected)
        eyeButton.tintColor = .systemGray3
        eyeButton.addTarget(self, action: #selector(toggleSecureEntry), for: .touchUpInside)
        
        addSubview(eyeButton)
        eyeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(eyeButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSuffixLabel(text: String) {
        suffixLabel.text = text
        suffixLabel.font = .systemFont(ofSize: 16, weight: .medium)
        suffixLabel.textColor = .black
        suffixLabel.textAlignment = .right
        addSubview(suffixLabel)
        suffixLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(suffixLabel.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func toggleSecureEntry() {
        eyeButton.isSelected.toggle()
        textField.isSecureTextEntry = !eyeButton.isSelected
        
        // 修正切换明暗文时光标跳动的问题
        if textField.isFirstResponder {
            textField.becomeFirstResponder()
        }
    }
}
