//
//  InstantOnboardingOwnerVC.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/7.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

class InstantOnboardingOwnerVC: UIViewController {
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var pwdContentView: UIView!
    
    @IBOutlet weak var createOtherButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var pwdAgainEyeButton: UIButton!
    @IBOutlet weak var pwdEyeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var againPwdTextField: UITextField!
    @IBOutlet weak var pwdAgainContentView: UIView!
    @IBOutlet weak var accoundContentView: UIView!
    static let defaultChatmailDomain: String = "nine.testrun.org"

    private var dcContext: DcContext
    private let dcAccounts: DcAccounts
    var loginParam:DcEnteredLoginParam?

    private var qrCodeReader: QrCodeReaderController?
    private var securityScopedResource: NSURL?
    private lazy var canCancel: Bool = {
        // "cancel" removes selected unconfigured account, so there needs to be at least one other account
        return dcAccounts.getAll().count >= 2
    }()

    var contentView: InstantOnboardingView? { view as? InstantOnboardingView }
    
    var avatorimage:UIImage?

    private var providerHostURL: URL
    private var qrCodeData: String?
    private lazy var menuButton: UIBarButtonItem = {
        let image = UIImage(systemName: "ellipsis.circle")
        return UIBarButtonItem(image: image, menu: moreButtonMenu())
    }()

    private lazy var proxyShieldButton: UIBarButtonItem = {
        let image = UIImage(systemName: "checkmark.shield")
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showProxySettings))
    }()

    var progressAlertHandler: ProgressAlertHandler?

    // TODO: Maybe use DI instead of lazily computed property?
    private lazy var mediaPicker: MediaPicker = {
        let mediaPicker = MediaPicker(dcContext: dcContext, navigationController: navigationController)
        mediaPicker.delegate = self
        return mediaPicker
    }()
    
    /// Creates Instant Onboarding-Screen. You can inject some QR-Code-Data to change the chatmail provider
    /// If `qrCodeData` is `nil`, the default server is used
    /// - Parameters:
    ///   - dcAccounts: Account to be used
    ///   - qrCodeData: DeltaChat QR Code Data
    init(dcAccounts: DcAccounts, qrCodeData: String? = nil) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()

        if let qrCodeData {
            let parsedQrCode = dcContext.checkQR(qrCode: qrCodeData)
            if parsedQrCode.state == DC_QR_LOGIN || parsedQrCode.state == DC_QR_ACCOUNT,
               let host = parsedQrCode.text1,
               let url = URL(string: "https://\(host)") {
                self.providerHostURL = url
                self.qrCodeData = qrCodeData
            } else {
                self.providerHostURL = URL(string: "https://" + InstantOnboardingViewController.defaultChatmailDomain)!
                self.qrCodeData = nil
            }
        } else {
            self.providerHostURL = URL(string: "https://" + InstantOnboardingViewController.defaultChatmailDomain)!
            self.qrCodeData = nil
        }

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        title = String.localized("pref_profile_info_headline")

        NotificationCenter.default.addObserver(self, selector: #selector(InstantOnboardingOwnerVC.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InstantOnboardingOwnerVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InstantOnboardingOwnerVC.connectivityChanged(_:)), name: Event.connectivityChanged, object: nil)

        navigationItem.setRightBarButtonItems([menuButton], animated: true)
        updateProxyButton()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

//    override func loadView() {
//        super.loadView()
//        let customProvider: String?
//        if qrCodeData != nil {
//            customProvider = providerHostURL.host
//        } else {
//            customProvider = nil
//        }
//        let contentView = InstantOnboardingView(avatarImage: dcContext.getSelfAvatarImage(), name: dcContext.displayname, customProvider: customProvider)
//        contentView.agreeButton.addTarget(self, action: #selector(InstantOnboardingOwnerVC.acceptAndCreateButtonPressed), for: .touchUpInside)
//        contentView.imageButton.addTarget(self, action: #selector(InstantOnboardingOwnerVC.onAvatarTapped), for: .touchUpInside)
//        contentView.privacyButton.addTarget(self, action: #selector(InstantOnboardingOwnerVC.showPrivacy(_:)), for: .touchUpInside)
//        contentView.otherOptionsButton.addTarget(self, action: #selector(InstantOnboardingOwnerVC.showOtherOptions(_:)), for: .touchUpInside)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(InstantOnboardingOwnerVC.textDidChangeNotification(notification:)),
//            name: UITextField.textDidChangeNotification,
//            object: contentView.nameTextField
//        )
//
//        self.view = contentView
//    }

    override func viewDidLoad() {
        contentView?.nameTextField.becomeFirstResponder()
        
        self.accoundContentView.layer.borderColor = UIColor.separator.cgColor
        self.accoundContentView.layer.borderWidth = 0.5
        self.accoundContentView.layer.cornerRadius = 8
        
        self.pwdContentView.layer.borderColor = UIColor.separator.cgColor
        self.pwdContentView.layer.borderWidth = 0.5
        self.pwdContentView.layer.cornerRadius = 8
        
        
        self.pwdAgainContentView.layer.borderColor = UIColor.separator.cgColor
        self.pwdAgainContentView.layer.borderWidth = 0.5
        self.pwdAgainContentView.layer.cornerRadius = 8
        
        againPwdTextField.isSecureTextEntry = true
        pwdTextField.isSecureTextEntry = true;
        

        self.createButton.layer.cornerRadius = 8
        
        self.createButton.layer.cornerRadius = 8
        
        self.avatarButton.layer.cornerRadius = 82/2.0
        self.avatarButton.layer.borderColor = UIColor.lightGray.cgColor
        self.avatarButton.layer.borderWidth = 0.5
        self.avatarButton.clipsToBounds = true
        
//        self.avatarButton.setImage(UIImage(named: "AA_Login_Logo"), for: .normal)
        self.view.backgroundColor = DcColors.defaultBackgroundColor
        
        self.createButton.backgroundColor = DcColors.primary
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateMenuButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        storeImageAndName()
    }
    @IBAction func didClickEyeAgainButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        againPwdTextField.isSecureTextEntry = !sender.isSelected
    }
    @IBAction func didClickEyeButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        pwdTextField.isSecureTextEntry = !sender.isSelected

    }
    
    // MARK: - Notifications
    @IBAction func didClickAvatarButton(_ sender: Any) {
        
        self.onAvatarTapped()
    }
    
    @IBAction func didClickCreateAccountButton(_ sender: UIButton) {
        
        
        if self.nameTextField.text?.isEmpty == true {
            ProgressHUD.failed("请输入名字")
            return
        }
        
        if self.accountTextField.text?.isEmpty == true {
            ProgressHUD.failed("请输入邮箱")
            return
        }
        
        if self.pwdTextField.text?.isEmpty == true {
            ProgressHUD.failed("请输入密码")
            return
        }
        
        if self.againPwdTextField.text?.isEmpty == true {
            ProgressHUD.failed("请输入确认密码")
            return
        }
        
        if self.againPwdTextField.text != self.pwdTextField.text {
            ProgressHUD.failed("两次输入的密码不一致")
            return
        }
        
//        {"domain":"aa1234.com","address":"test12@aa1234.com","password":"123456"}
        // 示例 1: 发送简单的 POST 请求
        
        let domain = "aa1234.com"

        let address = "\(self.accountTextField.text ?? "")@\(domain)"

        let pwd = self.pwdTextField.text ?? "123456"
        
           let loginData = [
            "domain":domain,
               "address":address ,
               "password": pwd
           ]
        
        
    
        print("loginData:\(loginData)")
        ProgressHUD.animate("登录中...")
        


        APIService.shared.sendPostRequest(
              to: "http://aa.aa1234.com/create-account",
              parameters: loginData,
              contentType: .json
          ) { (result: Result<LoginResponse, Error>) in
              switch result {
              case .success(let response):
                  print("登录成功: \(response)")
                  // 保存 token 等操作
                  
                  DispatchQueue.main.async {
                      if response.success == true && response.account.isEmpty == false {
                          ProgressHUD.dismiss()

                          
                          if self.dcContext.isConfigured() {
                              let accountId = self.dcContext.id
                              _ = self.dcAccounts.remove(id: accountId)
                              KeychainManager.deleteAccountSecret(id: accountId)
                              _ = self.dcAccounts.add()
                          }else{
//                                                      let newID = self.dcAccounts.add()
                              
                          }
                          self.dcContext = self.dcAccounts.getSelected()
                          
                          if let avatorimage = self.avatorimage {
                              AvatarHelper.saveSelfAvatarImage(dcContext: self.dcContext, image: avatorimage)

                          }
//                          self.dcAccounts.di
                         var parm =  DcEnteredLoginParam.init(addr: address, password: pwd)
                          parm.imapServer =  "mail.\(domain)"
                          parm.smtpServer = "mail.\(domain)";
                          
                          self.loginParam = parm;
                          
                          self.acceptOwnewAndCreateButtonPressed()
                          
                      }else if response.error.isEmpty == false && response.success == false{
                          ProgressHUD.failed("\(response.error)",delay: 3)
                      }else{
                          ProgressHUD.failed("登录失败",delay: 3)

                      }
                  }
                  
               
              case .failure(let error):
                  print("登录失败: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      ProgressHUD.dismiss()

                      ProgressHUD.failed("\(error.localizedDescription)",delay: 3)
                  }
              }
          }
    }
    @IBAction func didClickOtherCreatButton(_ sender: UIButton) {
        self.showOtherOptions(sender)
    }
    @objc func textDidChangeNotification(notification: Notification) {
        guard let textField = notification.object as? UITextField,
              let text = textField.text else { return }

        contentView?.validateTextfield(text: text)
    }

    @objc func connectivityChanged(_ notification: Notification) {
        guard dcContext.id == notification.userInfo?["account_id"] as? Int else { return }

        DispatchQueue.main.async { [weak self] in
            self?.updateMenuButtons()
        }
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
        contentView?.imageButton.setImage(UIImage(named: "camera"), for: .normal)
        self.avatarButton.setImage(UIImage(named: "camera"), for: .normal)
        self.avatorimage = nil;

    }

    @objc private func showPrivacy(_ sender: UIButton) {
        let url = providerHostURL.appendingPathComponent("/privacy.html")

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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

    @objc private func showOtherOptions(_ sender: UIButton) {
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

//                let accountSetupController = AccountSetupController(dcAccounts: self.dcAccounts, editView: false)
//                accountSetupController.onLoginSuccess = {
//                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                        appDelegate.reloadDcContext()
//                    }
//                }
//                self.navigationController?.pushViewController(accountSetupController, animated: true)
            }
        }

        let scanQRCode = UIAlertAction(title: String.localized("scan_invitation_code"), style: .default) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                let qrReader = QrCodeReaderController(title: String.localized("scan_invitation_code"))
                qrReader.delegate = self

                navigationController?.pushViewController(qrReader, animated: true)

                self.qrCodeReader = qrReader
            }
        }

        let cancelAction = UIAlertAction(title: String.localized("cancel"), style: .cancel)

        alertController.addAction(otherServersAction)
        alertController.addAction(manualAccountSetup)
        alertController.addAction(scanQRCode)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func moreButtonMenu() -> UIMenu {
        let actions = [
            UIAction(title: String.localized("proxy_use_proxy"), image: UIImage(systemName: "shield")) { [weak self] _ in
                self?.showProxySettings()
            },
        ]
        return UIMenu(children: actions)
    }

    @objc private func showProxySettings() {
        let proxySettingsController = ProxySettingsViewController(dcContext: dcContext, dcAccounts: dcAccounts)
        navigationController?.pushViewController(proxySettingsController, animated: true)
    }

    private func updateMenuButtons() {
        if dcContext.getProxies().isEmpty {
            navigationItem.setRightBarButtonItems([menuButton], animated: true)
        } else {
            navigationItem.setRightBarButtonItems([proxyShieldButton], animated: true)
        }

        updateProxyButton()
    }

    private func updateProxyButton() {
        if dcContext.isProxyEnabled {
            proxyShieldButton.image = UIImage(systemName: "checkmark.shield")
        } else {
            proxyShieldButton.image = UIImage(systemName: "shield")
        }
    }

    // MARK: - Notifications
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              var keyboardFrame: CGRect = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
              let contentView = contentView else { return }

        keyboardFrame = view.convert(keyboardFrame, from: nil)

        var contentInset = contentView.contentScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20

        contentView.contentScrollView.contentInset = contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        contentView?.contentScrollView.contentInset = UIEdgeInsets.zero
    }

    // MARK: - action: configuration
    @objc private func acceptAndCreateButtonPressed() {
        let progressAlertHandler = ProgressAlertHandler(notification: Event.configurationProgress, onSuccess: { [weak self] in
            self?.handleCreateSuccess()
        })
        progressAlertHandler.dataSource = self
        progressAlertHandler.showProgressAlert(title: String.localized("add_account"), dcContext: self.dcContext)

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            let qrCodeData = self.qrCodeData ?? "dcaccount:https://nine.testrun.org/new"
            do {
                _ = try self.dcContext.addTransportFromQr(qrCode: qrCodeData)
            } catch {
                DispatchQueue.main.async {
                    progressAlertHandler.updateProgressAlert(error: error.localizedDescription)
                }
            }

        }

        self.progressAlertHandler = progressAlertHandler
    }
    
    
    // MARK: - action: configuration
    @objc private func acceptOwnewAndCreateButtonPressed() {
        let progressAlertHandler = ProgressAlertHandler(notification: Event.configurationProgress, onSuccess: { [weak self] in
            self?.handleCreateSuccess()
        })
        progressAlertHandler.dataSource = self
        progressAlertHandler.showProgressAlert(title: String.localized("add_account"), dcContext: self.dcContext)
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            do {
                
                guard let loginParam = self.loginParam else { return  }
                
                _ = try self.dcContext.addOrUpdateTransport(param: loginParam)
                
            } catch {
                DispatchQueue.main.async {
                    progressAlertHandler.updateProgressAlert(error: error.localizedDescription)
                }
            }
            
        }
        
        self.progressAlertHandler = progressAlertHandler
    }


    private func handleCreateSuccess() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.registerForNotifications()
            appDelegate.reloadDcContext()
            appDelegate.prepopulateWidget()
        }
    }

    private func storeImageAndName() {
        dcContext.displayname = contentView?.nameTextField.text
        
        dcContext.displayname = nameTextField.text

    }
}

// MARK: - MediaPickerDelegate
extension InstantOnboardingOwnerVC: MediaPickerDelegate {
    func onImageSelected(image: UIImage) {
        AvatarHelper.saveSelfAvatarImage(dcContext: dcContext, image: image)
        contentView?.imageButton.setImage(image, for: .normal)
        
        self.avatarButton.setImage(image, for: .normal)
        
        self.avatorimage = image;
    }
}

// MARK: - QrCodeReaderDelegate
extension InstantOnboardingOwnerVC: QrCodeReaderDelegate {
    func handleQrCode(_ qrCode: String) {
        // update with new code
        let parsedQrCode = dcContext.checkQR(qrCode: qrCode)
        if parsedQrCode.state == DC_QR_LOGIN || parsedQrCode.state == DC_QR_ACCOUNT,
           let host = parsedQrCode.text1,
           let url = URL(string: "https://\(host)") {
            self.providerHostURL = url
            self.qrCodeData = qrCode

            contentView?.updateContent(with: host)
            dismissQRReader()
        } else {
            qrErrorAlert()
        }
    }

    private func qrErrorAlert() {
        let title = String.localized("qraccount_qr_code_cannot_be_used")
        let alert = UIAlertController(title: title, message: dcContext.lastErrorString, preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: String.localized("ok"),
            style: .default,
            handler: { [weak self] _ in
                self?.qrCodeReader?.startSession()
            }
        )
        alert.addAction(okAction)
        qrCodeReader?.present(alert, animated: true, completion: nil)
    }

    private func dismissQRReader() {
        self.navigationController?.popViewController(animated: true)
        self.qrCodeReader = nil
    }
}
