//
//  AddFriendViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/9.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import DcCore

import UIKit
import SnapKit

class AddFriendViewController: UIViewController, UITextViewDelegate {

    // MARK: - UI Components
    
    // MARK: - UI Components
    
    let dcContext:DcContext

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        // 添加阴影让卡片更有层次感
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 15
        return view
    }()

    private let customTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor // 细微的边框更精致
        tv.backgroundColor = .systemBackground
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.isScrollEnabled = false
        return tv
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system) // 使用 system 类型会有点击缩放反馈
        button.setTitle("发送申请", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = DcColors.primary
        button.setTitleColor(.white, for: .normal)
        
        // 在 iOS 14 中手动设置圆角
        button.layer.cornerRadius = 25 // 高度的一半实现胶囊形状
        
        // 增加一点按钮阴影
        button.layer.shadowColor = DcColors.primary.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 8
        
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        return button
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system) // 使用 system 类型会有点击缩放反馈
        button.setTitle("剪切板输入", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = DcColors.primary
        button.setTitleColor(.white, for: .normal)
        
        // 在 iOS 14 中手动设置圆角
        button.layer.cornerRadius = 25 // 高度的一半实现胶囊形状
        
        // 增加一点按钮阴影
        button.layer.shadowColor = DcColors.primary.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 8
        
        button.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        return button
    }()


    // 占位文字 Label (TextView 原生不支持 placeholder)
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入好友链接"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        return label
    }()

    
    init(dcContext: DcContext) {
        self.dcContext = dcContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        self.title = "添加好友"
        // 点击背景收起键盘
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(containerView)
        containerView.addSubview(customTextView)
        view.addSubview(confirmButton)
        containerView.addSubview(copyButton)

        customTextView.addSubview(placeholderLabel)
        customTextView.delegate = self

        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-40)
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(self.view.snp_topMargin).offset(20)
        }

        customTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(50)
            make.height.lessThanOrEqualTo(150)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(customTextView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(50) // 固定高度 50，对应的 cornerRadius 是 25
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(50)
//            make.bottom.equalToSuperview().offset(-25)
            make.height.equalTo(50) // 固定高度 50，对应的 cornerRadius 是 25
        }
    }
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        // 1. 控制 Placeholder 显示与隐藏
        
        let text = textView.text
        print("text:\(text)")
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // 2. 动态计算高度
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 3. 当高度变化时，SnapKit 会自动触发布局更新
//        if newSize.height >= 150 {
//            textView.isScrollEnabled = true
//        } else {
//        }
        
        // 通知父视图重新布局（带动画效果）
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleConfirm(){
        
        let text = self.customTextView.text ?? ""
        let urlStr = DeltaChatLinkConverter.openPGP4FPRToDeltaChat(text) ?? ""

        let url = URL.init(string: urlStr)
       if let url = url, url.isDeltaChatInvitation,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let appCoordinator = appDelegate.appCoordinator {
           appCoordinator.handleDeltaChatInvitation(url: url, from: self)
       }else if text.isValidEmail == true{
           self.askToChatWith(email: text)
       }
        
        else{
           ProgressHUD.failed("请输入正确的邀请链接")
       }
    }
    
    @objc func handleCopy(){
        self.customTextView.text = UIPasteboard.general.string;
        self.textViewDidChange(self.customTextView)
    }
    
    private func confirmationAlert(title: String, message: String? = nil, actionTitle: String, actionStyle: UIAlertAction.Style = .default, actionHandler: @escaping ((UIAlertAction) -> Void), cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .safeActionSheet)
        alert.addAction(UIAlertAction(title: actionTitle, style: actionStyle, handler: actionHandler))

        alert.addAction(UIAlertAction(title: String.localized("cancel"), style: .cancel, handler: cancelHandler ?? { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func askToChatWith(email: String) {
        var contactId = self.dcContext.lookupContactIdByAddress(email)
        if contactId == 0 {
            contactId = dcContext.createContact(name: "", email: email)
        }

        if dcContext.getChatIdByContactId(contactId) != 0 {
            self.dismiss(animated: true, completion: nil)
            let chatId = self.dcContext.createChatByContactId(contactId: contactId)
            self.showChat(chatId: chatId)
        } else {
            confirmationAlert(title: String.localizedStringWithFormat(String.localized("ask_start_chat_with"), email),
                              actionTitle: String.localized("start_chat"),
                              actionHandler: { _ in
                self.dismiss(animated: true, completion: nil)
                let chatId = self.dcContext.createChatByContactId(contactId: contactId)
                self.showChat(chatId: chatId)})
        }
    }
    
    func showChat(chatId: Int, messageId: Int? = nil, animated: Bool = true) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.appCoordinator.showChat(chatId: chatId, msgId: messageId, animated: animated, clearViewControllerStack: true)
        }
    }
}

import Foundation

extension String {
    /// 判断是否是合法的邮箱格式
    var isValidEmail: Bool {
        // 正则表达式逻辑：
        // 1. 开头是字母、数字、下划线、点或百分号等
        // 2. 必须包含 @ 符号
        // 3. 域名部分包含字母、数字、点或横线
        // 4. 后缀至少为两个字母（如 .com, .cn）
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
