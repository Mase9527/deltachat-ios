//
//  KeyInputViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/14.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//


import UIKit
import SnapKit
import DcCore

class KeyInputViewController: UIViewController, UITextViewDelegate {

    
    let mail:String
    let password:String
    
    var loginParam:DcEnteredLoginParam?

     var dcContext: DcContext
     let dcAccounts: DcAccounts
    
    var loginTool:AALoginAccountTool?

    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 容器 View 用于包含 TextView 和 粘贴按钮
    private let keyInputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        return view
    }()
    
    private lazy var keyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.isScrollEnabled = false // 重要：禁用滚动以撑开高度
        tv.delegate = self
        tv.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 80) // 给右侧按钮预留空间
        tv.isEditable = false
        return tv
    }()
    
    // 模拟 Placeholder
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "秘钥"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let pasteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("粘贴秘钥", for: .normal)
        btn.setTitleColor(.systemOrange, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return btn
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("确认", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemOrange
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let resetKeyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("重置秘钥", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [keyInputContainer, confirmButton, resetKeyButton])
        sv.axis = .vertical
        sv.spacing = 25
        sv.distribution = .fill
        return sv
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        
        self.loginTool = AALoginAccountTool(dcAccounts: self.dcAccounts, currentVC: self)

        self.resetKeyButton.addTarget(self, action: #selector(showResetAlert), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        title = "登录"
        // 这里的图标可以用系统的或者自定义
        let icon = UIImageView(image: UIImage(systemName: "pawprint.fill"))
        icon.tintColor = .orange
        navigationItem.titleView = icon // 简单模拟中间的图标+文字
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 245/255, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        keyInputContainer.addSubview(keyTextView)
        keyTextView.addSubview(placeholderLabel)
        keyInputContainer.addSubview(pasteButton)
        
        pasteButton.addTarget(self, action: #selector(handlePaste), for: .touchUpInside)
        
        confirmButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 自适应输入框容器
        keyInputContainer.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(55) // 设置最小高度
        }
        
        keyTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(16)
        }
        
        pasteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(placeholderLabel)
        }
        
        [confirmButton, resetKeyButton].forEach { btn in
            btn.snp.makeConstraints { make in
                make.height.equalTo(55)
            }
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
    
    @objc private func handlePaste() {
        if let string = UIPasteboard.general.string {
            keyTextView.text = string
            textViewDidChange(keyTextView)
            
            placeholderLabel.isHidden = !string.isEmpty

        }
    }
    
    @objc private func loginAction() {
        
        if self.keyTextView.text?.isEmpty == true {
            ProgressHUD.failed("请输入密钥")
            return
        }
        
        self.dcAccounts.stopIo()

        self.loginTool?.login(name: "", email: self.mail, password: self.password, key:  self.keyTextView.text ?? "")
    }
    
    // MARK: - Logic Actions
        @objc private func showResetAlert() {
            let alert = UIAlertController(title: "提示",
                                          message: "重置秘钥则成为一个全新独立账号，与旧秘钥互不相关",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
                print("执行重置秘钥逻辑")
                self.keyTextView.text =  self.dcContext.createKeypair(email: self.mail)

            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            present(alert, animated: true)
        }
}
