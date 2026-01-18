//
//  KeySuccessViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

import UIKit
import SnapKit

import UIKit
import SnapKit

class CenterAlertPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    // 强制系统使用 Auto Layout 计算位置
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 关键：在这里强制 presentedView 居中并确定宽度
        // 这样它的高度就会由内部的 SnapKit 约束自动撑开
        presentedView?.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

class KeySuccessViewController: UIViewController {
    
    var key:String
    var resetAction:ResetKeyAlertAction?
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .black
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        return btn
    }()
    
    private let alertIcon = UIImageView(image: UIImage(named: "key_Copy_Sucess")) // 替换为你的三角形警告图
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "秘钥生成成功，请妥善保管"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.numberOfLines = 5
        label.textAlignment = .center
        return label
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("复制秘钥", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 26
        return btn
    }()
    
    init(key:String, resetAction: ResetKeyAlertAction? = nil) {
        self.resetAction = resetAction
        self.key = key
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        self.messageLabel.text = key
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(alertIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(confirmButton)
        
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.size.equalTo(30)
        }
        
        alertIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(128)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(alertIcon.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(30)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-24)
            make.top.equalTo(messageLabel.snp.bottom).offset(42)
            make.height.equalTo(52)
        }
    }
    
    @objc private func dismissSelf() {
//        dismiss(animated: true)
        dismiss(animated: true) {[weak self] in
            guard let self = self else {return}
            guard let resetAction = resetAction else { return  }
            resetAction()
        }
    }
    
    @objc private func handleConfirm() {
        print("确认重置")
        UIPasteboard.general.string = key
        dismiss(animated: true) {[weak self] in
            guard let self = self else {return}
            guard let resetAction = resetAction else { return  }
            resetAction()
        }
        
    
    }
}
    
// MARK: - 转场代理
extension KeySuccessViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AACenterPopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
