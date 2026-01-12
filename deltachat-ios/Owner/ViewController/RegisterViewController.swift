//
//  RegisterViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/12.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import DcCore

class RegisterViewController: UIViewController {

    // TODO: Maybe use DI instead of lazily computed property?
    private lazy var mediaPicker: MediaPicker = {
        let mediaPicker = MediaPicker(dcContext: dcContext, navigationController: navigationController)
        mediaPicker.delegate = self
        return mediaPicker
    }()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var dcContext: DcContext
    private let dcAccounts: DcAccounts
    var loginParam:DcEnteredLoginParam?
    var avatorimage:UIImage?
    
    var tokenModel:RequestTokenModel?
    // 使用 StackView 管理所有输入组件
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()

    // 头像占位
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
     
        return iv
    }()

    // 输入框定义
    private let nameField = CustomTextField(placeholder: "你的名字")
    private let accountField = CustomTextField(placeholder: "请输入账号", rightSuffix: "@aa1234.com")
    private let passwordField = CustomTextField(placeholder: "请输入密码", isSecure: true)
    private let confirmPasswordField = CustomTextField(placeholder: "请确认输入密码", isSecure: true)
    private let backupEmailField = CustomTextField(placeholder: "备用邮箱（用于找回）")
    
    // 验证码区域
    private let verifyCodeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    private let verifyCodeField = CustomTextField(placeholder: "验证码")
    private let sendCodeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("发送验证码", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 8
        return btn
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("同意并创建账号", for: .normal)
        btn.backgroundColor = .systemOrange // 橙色
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let otherButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("使用其他服务器", for: .normal)
//        btn.backgroundColor = .systemOrange // 橙色
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    

    // MARK: - Properties
    private var countdownTimer: Timer?
    private var remainingSeconds = 60
    
    
    init(dcAccounts: DcAccounts) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()

 

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
 
        
//        // 点击空白收起键盘
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
//        IQKeyboardManager.shared.keyboardDistance = 50;
//        IQKeyboardManager.shared.isEnabled = true;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped))
        self.avatarImageView.addGestureRecognizer(tap)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        IQKeyboardManager.shared.keyboardDistance = 50;
        IQKeyboardManager.shared.isEnabled = true;
        
//        self.backupEmailField.textField.text = "ios@aa1234.com";

    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false;

    }

    private func setupUI() {
        title = "您的个人资料"
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(mainStackView)
        
        // 组装验证码行
        verifyCodeStack.addArrangedSubview(verifyCodeField)
        verifyCodeStack.addArrangedSubview(sendCodeButton)
        sendCodeButton.snp.makeConstraints { $0.width.equalTo(100) }
        
        // 组装主列表
        [nameField, accountField, passwordField, confirmPasswordField,
         backupEmailField, verifyCodeStack, registerButton,otherButton].forEach {
            mainStackView.addArrangedSubview($0)
            $0.snp.makeConstraints { $0.height.equalTo(48) }
        }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().offset(-40) // 确保 contentSize 足够
        }
    }

    private func setupActions() {
        sendCodeButton.addTarget(self, action: #selector(handleSendCode), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        passwordField.eyeButton.addTarget(self, action: #selector(didClickEyePasswordFieldButton), for: .touchUpInside)
        confirmPasswordField.eyeButton.addTarget(self, action: #selector(didClickEyeconfirmPasswordFieldButton), for: .touchUpInside)
        otherButton.addTarget(self, action: #selector(showOtherOptions), for: .touchUpInside)


    }
    
    @objc func didClickEyePasswordFieldButton(){
        self.passwordField.eyeButton.isSelected =  !self.passwordField.eyeButton.isSelected
        self.passwordField.textField.isSecureTextEntry = !self.passwordField.eyeButton.isSelected
    }
    
    @objc func didClickEyeconfirmPasswordFieldButton(){
        self.confirmPasswordField.eyeButton.isSelected =  !self.confirmPasswordField.eyeButton.isSelected
        self.confirmPasswordField.textField.isSecureTextEntry = !self.confirmPasswordField.eyeButton.isSelected


    }

    // MARK: - Logic
    @objc private func handleSendCode() {
        // 对应导图中的“滑动验证”
//        showSliderVerify { [weak self] success in
//            if success {
//                self?.startCountdown()
//                print("发送验证码至: \(self?.backupEmailField.text ?? "")")
//            }
//        }
        
        
        if self.nameField.text?.isEmpty == true {
            ProgressHUD.failed("请输入名字")
            return
        }
        
        if self.accountField.text?.isEmpty == true {
            ProgressHUD.failed("请输入邮箱")
            return
        }
        
        if self.passwordField.text?.isEmpty == true {
            ProgressHUD.failed("请输入密码")
            return
        }
        
        if self.confirmPasswordField.text?.isEmpty == true {
            ProgressHUD.failed("请输入确认密码")
            return
        }
        
        if self.passwordField.text != self.confirmPasswordField.text {
            ProgressHUD.failed("两次输入的密码不一致")
            return
        }
        
        let recovery_email = self.backupEmailField.text ?? ""
        
        if recovery_email.isValidEmail == false {
            ProgressHUD.failed("请输入正确的备用邮箱")
            return
        }

        
        /// 发送验证码
        ProgressHUD.animate("发送验证码...")

        let address = "\(accountField.text ?? "")@\(domain)"
       
        
        let apiBing = iFBaseAPI.bindRecoveryRequest(main_email:address, recovery_email: recovery_email)
        HttpClient.shareInstance.request(target: apiBing) {[weak self] data in
            
            let decoder = JSONDecoder()
            let result = try? decoder.decode(RequestTokenModel.self, from: data)
            self?.tokenModel = result
            if let tokenModel = result,tokenModel.success == true{
                ProgressHUD.dismiss()
                self?.startCountdown()
            }else{
                ProgressHUD.failed("\(String(describing: result?.error))",delay: 3)

            }

        }failure: { code, msg in
         
            ProgressHUD.failed("\(String(describing: msg))",delay: 3)

        }
        
    }

    private func startCountdown() {
        sendCodeButton.isEnabled = false
        remainingSeconds = 60
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.sendCodeButton.setTitle("\(self.remainingSeconds)s", for: .normal)
            if self.remainingSeconds <= 0 {
                timer.invalidate()
                self.sendCodeButton.isEnabled = true
                self.sendCodeButton.setTitle("发送验证码", for: .normal)
            }
        }
    }
    
    @objc
    private func onAvatarTapped() {
        let alert = UIAlertController(title: String.localized("pref_profile_photo"), message: nil, preferredStyle: .safeActionSheet)
        alert.addAction(PhotoPickerAlertAction(title: String.localized("camera"), style: .default, handler: cameraButtonPressed(_:)))
        alert.addAction(PhotoPickerAlertAction(title: String.localized("gallery"), style: .default, handler: galleryButtonPressed(_:)))
        if dcContext.getSelfAvatarImage() != nil {
            alert.addAction(UIAlertAction(title: String.localized("delete"), style: .destructive, handler: deleteProfileIconPressed(_:)))
        }
        alert.addAction(UIAlertAction(title: String.localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    @objc private func showOtherOptions() {
        let alertController = UIAlertController(title: String.localized("instant_onboarding_show_more_instances"), message: nil, preferredStyle: .safeActionSheet)
        let otherServersAction = UIAlertAction(title: String.localized("instant_onboarding_other_server"), style: .default) { [weak self] _ in

            self?.storeImageAndName()

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

    // MARK: - actions
    private func galleryButtonPressed(_ action: UIAlertAction) {
        mediaPicker.showGallery(allowCropping: true)
    }

    private func cameraButtonPressed(_ action: UIAlertAction) {
        mediaPicker.showCamera(allowCropping: true, supportedMediaTypes: .photo)
    }

    private func deleteProfileIconPressed(_ action: UIAlertAction) {
        dcContext.selfavatar = nil
        self.avatarImageView.image = UIImage(named: "camera")
        self.avatorimage = nil;

    }
    
    private func storeImageAndName() {
        
        dcContext.displayname = nameField.text

    }
    
    private func showSliderVerify(completion: @escaping (Bool) -> Void) {
        // 模拟滑动验证码弹窗
        let alert = UIAlertController(title: "滑动验证", message: "（此处应集成滑动验证码组件）", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "验证通过", style: .default) { _ in completion(true) })
        present(alert, animated: true)
    }

    @objc private func handleRegister() {
        print("点击注册，校验验证码: \(verifyCodeField.text ?? "")")
        
        if self.nameField.text?.isEmpty == true {
            ProgressHUD.failed("请输入名字")
            return
        }
        
        if self.accountField.text?.isEmpty == true {
            ProgressHUD.failed("请输入邮箱")
            return
        }
        
        if self.passwordField.text?.isEmpty == true {
            ProgressHUD.failed("请输入密码")
            return
        }
        
        if self.confirmPasswordField.text?.isEmpty == true {
            ProgressHUD.failed("请输入确认密码")
            return
        }
        
        if self.passwordField.text != self.confirmPasswordField.text {
            ProgressHUD.failed("两次输入的密码不一致")
            return
        }
        
        let recovery_email = self.backupEmailField.text ?? ""
        
        if recovery_email.isValidEmail == false {
            ProgressHUD.failed("请输入正确的备用邮箱")
            return
        }
        
        guard let tokenModel = tokenModel else {
            ProgressHUD.failed("请先发送验证码")
            return
        }
   
        let code = self.verifyCodeField.text ?? ""
        
        if code.count < 6 {
            ProgressHUD.failed("请输入正确的验证码")
            return
        }
        
        
        let domain = "aa1234.com"

        let address = "\(self.accountField.text ?? "")@\(domain)"
        let pwd = self.passwordField.text ?? "123456"

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
                        
                        
                        let testVC = AAPublicKeyPopupViewController(key: privateKeyText)
                        
                        testVC.copySucessAction = {
                            
                            
                            let domain = "aa1234.com"

                            let address = "\(self.accountField.text ?? "")@\(domain)"
                            
                            let loginVC = AALoginViewController(mail:address , password:self.passwordField.text ?? "" ,nickName:self.nameField.text ?? "AAMail" ,dcContext: self.dcContext,dcAccounts: self.dcAccounts)
                     
                            self.navigationController?.pushViewController(loginVC, animated: true)
                        }
                      self.present(testVC, animated: true)
                        

                        self.dcContext = self.dcAccounts.getSelected()
                        
//                        if let avatorimage = self.avatorimage {
//                            AvatarHelper.saveSelfAvatarImage(dcContext: self.dcContext, image: avatorimage)
//
//                        }
                    }failure: { code, msg in
                        ProgressHUD.failed("\(msg)",delay: 3)

                    }
                    
           


           //                          self.acceptOwnewAndCreateButtonPressed()
                    
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

// MARK: - 自定义带样式的输入框
class CustomTextField: UIView {
    let textField = UITextField()
    let eyeButton = UIButton(type: .custom)

    init(placeholder: String, isSecure: Bool = false, rightSuffix: String? = nil) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            if rightSuffix != nil {
                make.right.equalToSuperview().offset(-120)
            } else {
                make.right.equalToSuperview().offset(-15)
            }
        }
        
        if let suffix = rightSuffix {
            let label = UILabel()
            label.text = suffix
            label.textColor = .black
            label.font = .systemFont(ofSize: 16)
            addSubview(label)
            label.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
        }
        
        if isSecure {
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            eyeButton.setImage(UIImage(systemName: "eye"), for: .selected)

            eyeButton.tintColor = .systemOrange
            addSubview(eyeButton)
            eyeButton.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var text: String? { textField.text }
}


// MARK: - MediaPickerDelegate
extension RegisterViewController: MediaPickerDelegate {
    func onImageSelected(image: UIImage) {
        AvatarHelper.saveSelfAvatarImage(dcContext: dcContext, image: image)
//        contentView?.imageButton.setImage(image, for: .normal)
        
        self.avatarImageView.image = image
        
        self.avatorimage = image;
    }
}
