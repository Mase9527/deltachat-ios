//
//  ResetKeyAlertViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/16.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit

typealias ResetKeyAlertAction = ()->(Void)

class ResetKeyAlertViewController: UIViewController {
    
    
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
    
    private let alertIcon = UIImageView(image: UIImage(named: "key_reset_warrning")) // 替换为你的三角形警告图
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "重置秘钥"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "重置秘钥则成为一个全新的独立账号，与旧秘钥互不关联"
        label.font = .systemFont(ofSize: 18,weight: .bold)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 26
        return btn
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
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
    
    @objc private func dismissSelf() { dismiss(animated: true) }
    
    @objc private func handleConfirm() {
        print("确认重置")
        
        dismiss(animated: true)
        
        guard let resetAction = resetAction else { return  }
        resetAction()
    }
}

// MARK: - Transitioning Delegate
extension ResetKeyAlertViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AACenterPopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
