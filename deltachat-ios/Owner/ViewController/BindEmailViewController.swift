//
//  BindEmailViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DcCore

class BindEmailViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var dcContext: DcContext
    private let dcAccounts: DcAccounts
    var loginParam:DcEnteredLoginParam?
    var tokenModel:RequestTokenModel?

    var loginTool:AALoginAccountTool?

    
    var email:String
    var password:String
    
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
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("同意并创建账号", for: .normal)
        btn.backgroundColor = .orange
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 30
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return btn
    }()

    
    // 1. 邮箱输入
    let emailInput = InputView(image: "AA_Email_icon", placeholder: "备用邮箱(用于找回)")
    
    // 2. 验证码输入
    let codeInput = InputView(image: "AA_EmailCode_icon", placeholder: "输入验证码")
    
    init(dcAccounts: DcAccounts,email:String,password:String) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()
        self.email = email
        self.password = password
 

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
        
        IQKeyboardManager.shared.keyboardDistance = 150;
        IQKeyboardManager.shared.isEnabled = true;
        
        self.loginTool = AALoginAccountTool(dcAccounts: self.dcAccounts, currentVC: self)
        
        self.submitButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)

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
        
        // 头部背景图逻辑同上一个回答...
    }

    private func setupBusinessUI() {
        contentView.addSubview(stackView)
        contentView.addSubview(submitButton)
        
     
        
        // 3. 滑动验证
        let sliderVerify = SliderVerifyView()
        sliderVerify.onVerifySuccess = {
            print("触发发送验证码接口")
            self.handleSendCode()
        }
        
        [emailInput, codeInput, sliderVerify].forEach { view in
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
        
        // 5. 输入框 StackView (利用负偏移量实现“悬浮”在背景上的效果)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerBackground.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(40)
            make.leading.trailing.equalTo(stackView)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-50)
        }
        
        // 实现判断逻辑
                sliderVerify.shouldBeginSliding = { [weak self] in
                    guard let self = self else { return false }
                    
                    // 获取邮箱输入框的内容 (假设在 InputView 中公开了 textField)
                    let email = self.emailInput.textField.text ?? "" // 需要在 InputView 增加 getText 方法
                    
                    if email.isEmpty {
                        return false
                    }
                    
                    // 可选：增加邮箱格式的正则表达式判断
                    if email.isValidEmail == false {
                        return false
                    }
                    
                    return true
                }
                
                // 如果判断失败后的反馈
                sliderVerify.onVerifyDenied = { [weak self] in
                    
                    ProgressHUD.failed("请先输入有效的邮箱地址")
                }
    }
    
    // MARK: - Logic
    @objc private func handleSendCode() {

        /// 发送验证码
        ProgressHUD.animate("发送验证码...")

        let address = email
        let recovery_email = self.emailInput.textField.text ?? ""
       
        
        let apiBing = iFBaseAPI.bindRecoveryRequest(main_email:address, recovery_email: recovery_email)
        HttpClient.shareInstance.request(target: apiBing) {[weak self] data in
            
            let decoder = JSONDecoder()
            let result = try? decoder.decode(RequestTokenModel.self, from: data)
            self?.tokenModel = result
            if let tokenModel = result,tokenModel.success == true{
                ProgressHUD.dismiss()
//                self?.startCountdown()
            }else{
                ProgressHUD.failed("\(String(describing: result?.error))",delay: 3)

            }

        }failure: { code, msg in
         
            ProgressHUD.failed("\(String(describing: msg))",delay: 3)

        }
        
    }
    
    @objc private func handleRegister() {
        
        let recovery_email = self.emailInput.textField.text ?? ""
        
        if recovery_email.isValidEmail == false {
            ProgressHUD.failed("请输入正确的备用邮箱")
            return
        }
        
        guard let tokenModel = tokenModel else {
            ProgressHUD.failed("请先发送验证码")
            return
        }
   
        let code = self.codeInput.textField.text ?? ""
        
        if code.count < 6 {
            ProgressHUD.failed("请输入正确的验证码")
            return
        }
        
        

        let address = email
        let pwd = password

       let api = iFBaseAPI.createAccount(domain: domain, address: address, password: pwd)
       
        let apiBing = iFBaseAPI.bindRecoveryVerify(token: tokenModel.token, code: code)
        
        HttpClient.shareInstance.request(target: api) { data in
            
            let decoder = JSONDecoder()
            let result = try? decoder.decode(LoginResponse.self, from: data)
            
            
            DispatchQueue.main.async(execute: DispatchWorkItem.init(block: {
                if result?.success == true {

                    HttpClient.shareInstance.request(target: apiBing) { okdata in
                        ProgressHUD.dismiss()

                        let privateKeyText = self.dcContext.createKeypair(email: address)
                         logger.error("key:\(privateKeyText)")
                        
                        
                        let testVC = KeySuccessViewController(key: privateKeyText)
                      
                        
                        testVC.resetAction = { [weak self] in
                            
                            guard let self = self else { return  }
                            
                            self.loginTool?.login(name: "", email: self.email, password: self.password, key: privateKeyText)
                           
                        }
                      self.present(testVC, animated: true)
                        

                        self.dcContext = self.dcAccounts.getSelected()
                        

                    }failure: { code, msg in
                        ProgressHUD.failed("\(msg)",delay: 3)

                    }
                    
                }else if result?.success == false{
                    ProgressHUD.failed("\(String(describing: result?.error))",delay: 3)
                }else{
                    ProgressHUD.failed("登录失败",delay: 3)

                }
            }))
            
                    
        

        }failure: { code, msg in
            ProgressHUD.failed("登录失败",delay: 3)


        }
    }

}

import UIKit
import SnapKit

class SliderVerifyView: UIView {
    
    // 新增：询问外部是否允许滑动的闭包
        var shouldBeginSliding: (() -> Bool)?
        // 新增：如果不允许滑动，触发一个失败提示的回调（可选）
        var onVerifyDenied: (() -> Void)?
    
    
    // 回调闭合：验证成功后通知外部
    var onVerifySuccess: (() -> Void)?
    private var isFinished = false

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 30
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "右滑获取验证码"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let sliderBtn: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 26
        // 加阴影
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let icon = UIImageView(image: UIImage(systemName: "arrow.right"))
        icon.tintColor = .lightGray
        view.addSubview(icon)
        icon.snp.makeConstraints { make in make.center.equalToSuperview() }
        return view
    }()
    
    
    private let successView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1) // 蓝色背景
            view.layer.cornerRadius = 30
            view.alpha = 0 // 初始隐藏
            return view
        }()

        private let successLabel: UILabel = {
            let label = UILabel()
            label.text = "验证码获取成功"
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .bold)
            return label
        }()

        private let checkContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 25 // 圆形
            
            let icon = UIImageView(image: UIImage(systemName: "checkmark"))
            icon.tintColor = .systemGreen
            icon.contentMode = .scaleAspectFit
            view.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(25)
            }
            return view
        }()



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
            // 1. 基础滑动层布局
            addSubview(backgroundView)
            backgroundView.addSubview(titleLabel)
            backgroundView.addSubview(sliderBtn)
            
            // 2. 成功层布局
            addSubview(successView)
            successView.addSubview(successLabel)
            successView.addSubview(checkContainer)
            
            backgroundView.snp.makeConstraints { make in make.edges.equalToSuperview() }
            titleLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
            sliderBtn.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(5)
                make.centerY.equalToSuperview()
                make.size.equalTo(50)
            }
            
            // 成功状态布局
            successView.snp.makeConstraints { make in make.edges.equalToSuperview() }
            
            successLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            checkContainer.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-5)
                make.centerY.equalToSuperview()
                make.size.equalTo(50)
            }
        }

        // 关键交互：滑动结束后的状态转换
        private func showSuccessState() {
            isFinished = true
            onVerifySuccess?() // 通知控制器执行发送验证码逻辑

            // 触感反馈（可选，增加交互质感）
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            // 动画切换
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.successView.alpha = 1
                // 让原先的滑块也滑到最右侧并消失，视觉更连贯
                self.sliderBtn.alpha = 0
                self.layoutIfNeeded()
            } completion: { _ in
                // 成功后的后续逻辑，如开启倒计时
                // 模拟：1.5秒后开始进入倒计时或直接准备下次重置
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.startCountdown()
                        }
            }
        }
    

    private func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sliderBtn.addGestureRecognizer(pan)
    }

    @objc private func handleOldPan(_ gesture: UIPanGestureRecognizer) {
        guard !isFinished else { return }
        let translation = gesture.translation(in: self)
        let maxX = self.frame.width - sliderBtn.frame.width - 8
        
        switch gesture.state {
        case .changed:
            let x = max(4, min(translation.x + 4, maxX))
            sliderBtn.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(x)
            }
        case .ended:
            if sliderBtn.frame.minX >= maxX * 0.9 {
                showSuccessState()
            } else {
                // 回弹动画
                UIView.animate(withDuration: 0.3) {
                    self.sliderBtn.snp.updateConstraints { make in make.leading.equalToSuperview().offset(4) }
                    self.layoutIfNeeded()
                }
            }
        default: break
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard !isFinished else { return }
            
            // 关键逻辑：在手势开始时进行判断
            if gesture.state == .began {
                // 如果外部返回 false，则取消手势
                if let shouldStart = shouldBeginSliding, !shouldStart() {
                    onVerifyDenied?()
                    gesture.state = .cancelled // 强制取消当前手势
                    return
                }
            }
            
            let translation = gesture.translation(in: self)
            let maxX = self.frame.width - sliderBtn.frame.width - 8
            
            switch gesture.state {
            case .changed:
                let x = max(4, min(translation.x + 4, maxX))
                sliderBtn.snp.updateConstraints { make in
                    make.leading.equalToSuperview().offset(x)
                }
            case .ended:
                if sliderBtn.frame.minX >= maxX * 0.9 {
                    showSuccessState()
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.sliderBtn.snp.updateConstraints { make in make.leading.equalToSuperview().offset(4) }
                        self.layoutIfNeeded()
                    }
                }
            default: break
            }
        }
        
        // ... resetSlider 等其他方法 ...
    

    
    private func startCountdown() {
        var count = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if count > 0 {
                self.successLabel.text = "重新获取(\(count)s)"
                count -= 1
            } else {
                timer.invalidate()
                self.resetSlider() // 时间到，恢复初始滑动状态
            }
        }
    }
    
    // MARK: - Reset Logic
    func resetSlider() {
        // 1. 重置业务逻辑状态
        self.isFinished = false
        
        // 2. 恢复初始文字
        self.successLabel.text = "验证码获取成功"
        
        // 3. 执行 UI 动画回退
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            // 隐藏成功层
            self.successView.alpha = 0
            
            // 显示并重置滑块位置
            self.sliderBtn.alpha = 1
            self.sliderBtn.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(5)
            }
            
            // 强制重新布局
            self.layoutIfNeeded()
        } completion: { _ in
            // 可以在这里恢复标题文字，防止之前在倒计时
            self.titleLabel.text = "右滑获取验证码"
        }
    }
    
//    private func showSuccessState() {
//        isFinished = true
//        onVerifySuccess?()
//        UIView.animate(withDuration: 0.4) {
//            self.successView.alpha = 1
//        }
//    }
}
