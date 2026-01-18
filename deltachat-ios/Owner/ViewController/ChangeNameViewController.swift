//
//  ChangeNameViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

import UIKit
import SnapKit

class ChangeNameViewController: UIViewController {
    
    let name:String
    
    // 回调：将修改后的名字传回
    var onNameChanged: ((String) -> Void)?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 35
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "修改昵称"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.97, alpha: 1)
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入新昵称"
        tf.font = .systemFont(ofSize: 16)
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("确定修改", for: .normal)
        btn.backgroundColor = .systemOrange // 延续橙色风格
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 28
        return btn
    }()
    
    init(name:String ) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        [titleLabel, inputContainer, confirmButton].forEach { containerView.addSubview($0) }
        inputContainer.addSubview(textField)
        
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        
        // 点击背景关闭
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        inputContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(55)
        }
        
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(inputContainer.snp.bottom).offset(30)
            make.leading.trailing.equalTo(inputContainer)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-35) // 撑开高度的核心
        }
    }
    
    @objc private func handleConfirm() {
        guard let name = textField.text, !name.isEmpty else { return }
        onNameChanged?(name)
        dismiss(animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

// MARK: - 转场代理
extension ChangeNameViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AACenterPopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
