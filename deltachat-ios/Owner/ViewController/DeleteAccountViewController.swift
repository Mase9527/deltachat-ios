//
//  DeleteAccountViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import DcCore
import Intents

class DeleteAccountViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var dcContext: DcContext
    private let dcAccounts: DcAccounts
    private var tokenModel: RequestTokenModel?
    
    // 顶部背景区域
    private let headerBackground: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Create_top_icon") )
        view.backgroundColor = .systemRed // 注销通常用红色警示
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "注销账号"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "为了您的账号安全，请验证身份"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("确认注销", for: .normal)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 30
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return btn
    }()

    
    // 1. 邮箱显示 (只读)
    let emailDisplay: InputView = {
        let input = InputView(image: "AA_Email_icon", placeholder: "")
        input.textField.isUserInteractionEnabled = false // 只读
        input.textField.textColor = .gray
        return input
    }()
    
    // 2. 验证码输入
    let codeInput = InputView(image: "AA_EmailCode_icon", placeholder: "输入验证码")
    
    init(dcAccounts: DcAccounts) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
        setupBusinessUI()
        
        let currentEmail = dcContext.addr ?? ""
        emailDisplay.textField.text = currentEmail
        
        // 绑定按钮事件
        self.deleteButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
    }

    private func setupBaseUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.contentInsetAdjustmentBehavior = .never
        [headerBackground, titleLabel, subTitleLabel, stackView].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    private func setupBusinessUI() {
        contentView.addSubview(stackView)
        contentView.addSubview(deleteButton)
        
        // 3. 滑动验证
        let sliderVerify = SliderVerifyView()
        sliderVerify.onVerifySuccess = { [weak self] in
            print("触发发送验证码接口")
            self?.handleSendCode()
        }
        
        // 设置滑动验证的校验逻辑
        sliderVerify.shouldBeginSliding = { [weak self] in
            guard let self = self else { return false }
            // 这里不需要校验邮箱输入，因为是固定的当前账号
            // 但可以校验网络状态等，或者直接允许
            return true
        }
        
        [emailDisplay, codeInput, sliderVerify].forEach { view in
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in make.height.equalTo(60) }
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
        
        // 5. 输入框 StackView
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerBackground.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(stackView)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    // MARK: - Logic
    @objc private func handleSendCode() {
        ProgressHUD.animate("发送验证码...")
        
        guard let address = dcContext.addr else {
            ProgressHUD.failed("无法获取当前账号邮箱")
            return
        }
        
        let api = iFBaseAPI.deleteAccountRequest(main_email: address)
        HttpClient.shareInstance.request(target: api) { [weak self] data in
            let decoder = JSONDecoder()
            let result = try? decoder.decode(RequestTokenModel.self, from: data)
            self?.tokenModel = result
            if let tokenModel = result, tokenModel.success == true {
                ProgressHUD.dismiss()
                ProgressHUD.succeed("验证码已发送")
            } else {
                ProgressHUD.failed("\(String(describing: result?.error ?? "发送失败"))", delay: 3)
            }
        } failure: { code, msg in
            ProgressHUD.failed("\(String(describing: msg))", delay: 3)
        }
    }
    
    @objc private func handleDeleteAccount() {
        guard let tokenModel = tokenModel else {
            ProgressHUD.failed("请先发送验证码")
            return
        }
        
        let code = self.codeInput.textField.text ?? ""
        if code.count < 6 { // 假设验证码至少6位
            ProgressHUD.failed("请输入正确的验证码")
            return
        }
        
        let api = iFBaseAPI.deleteAccountVerify(token: tokenModel.token, code: code)
        ProgressHUD.animate("注销中...")
        
        HttpClient.shareInstance.request(target: api) { [weak self] data in
            // 假设 verify 接口返回 LoginResponse 或类似的成功结构
            // 这里我们只需要检查 success
            let decoder = JSONDecoder()
            // 尝试解析为通用响应，或者复用 LoginResponse 如果它包含 success 字段
            struct SimpleResponse: Decodable {
                let success: Bool?
                let error: String?
            }
            
            let result = try? decoder.decode(SimpleResponse.self, from: data)
            
            if result?.success == true {
                ProgressHUD.dismiss()
                self?.performLocalAccountDeletion()
            } else {
                ProgressHUD.failed("\(String(describing: result?.error ?? "验证失败"))", delay: 3)
            }
            
        } failure: { code, msg in
            ProgressHUD.failed("\(msg)", delay: 3)
        }
    }
    
    private func performLocalAccountDeletion() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let accountId = dcContext.id
        
        // 1. 停止位置共享
        appDelegate.locationManager.disableLocationStreamingInAllChats()
        
        // 2. 删除账号
        _ = dcAccounts.remove(id: accountId)
        KeychainManager.deleteAccountSecret(id: accountId)
        INInteraction.delete(with: "\(accountId)", completion: nil)
        
        // 3. 处理剩余账号逻辑
        if dcAccounts.getAll().isEmpty {
            _ = dcAccounts.add()
        } else {
            let lastSelectedAccountId = UserDefaults.standard.integer(forKey: Constants.Keys.lastSelectedAccountKey)
            if lastSelectedAccountId != 0 {
                _ = dcAccounts.select(id: lastSelectedAccountId)
            }
        }
        
        // 4. 重载并退出
        ProgressHUD.succeed("注销成功")
        
        // 延迟一点时间让用户看到成功提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            appDelegate.reloadDcContext()
            UserDefaults.standard.setValue(0, forKey: Constants.Keys.lastSelectedAccountKey) // 重置为0或特定值
            
            // 如果是在 TabBarController 或 NavigationController 中，可能需要重置窗口根视图
            // 参考 ProfileSwitchViewController 的 reloadAndExit
            // appDelegate.reloadDcContext() 通常会重置 window.rootViewController
        }
    }
}
