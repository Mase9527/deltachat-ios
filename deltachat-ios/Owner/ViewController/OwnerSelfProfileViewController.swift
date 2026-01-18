//
//  OwnerSelfProfileViewController.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2026/1/18.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import UIKit
import SnapKit
import DcCore


class OwnerSelfProfileViewController: UIViewController,MediaPickerDelegate {

    
    private let dcContext: DcContext
    
    var signatureView:SignatureSectionView!
    
    private var changeAvatar: UIImage?
    private var deleteAvatar: Bool = false
    
    private var hasName: Bool = false

    
    var lastStandardAppearance:UINavigationBarAppearance?
    var lastScrollEdgeAppearance:UINavigationBarAppearance?
    var lastCompactAppearance:UINavigationBarAppearance?

    
    
    init(dcAccounts: DcAccounts) {
        self.dcContext = dcAccounts.getSelected()
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var doneButton: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        item.tintColor = .white

        return item
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let item = UIBarButtonItem.init(image: UIImage(named: "AA_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(cancelButtonPressed))
        item.tintColor = .clear
//        let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        return item
    }()
    
    private lazy var mediaPicker: MediaPicker? = {
        let mediaPicker = MediaPicker(dcContext: dcContext, navigationController: navigationController)
        mediaPicker.delegate = self
        return mediaPicker
    }()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 顶部背景区域
    private let headerBackground: UIImageView = {
        let view = UIImageView(image: UIImage(named: "AA_profile_top_icon"))
        view.backgroundColor = .systemOrange // 顶部黄色背景
        return view
    }()
    
    // 主垂直堆栈视图
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
//        stack.backgroundColor = .green
        return stack
    }()
    
    // 头像和昵称部分
    private let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "avatar")) // 示例头像
        iv.layer.cornerRadius = 44
        iv.clipsToBounds = true
        iv.layer.borderWidth = 4
        iv.backgroundColor = .systemBlue
        iv.layer.borderColor = UIColor.white.cgColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let nicknameLabel:UIButton = {
      
        let button:UIButton
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = "你的昵称"
            config.image = UIImage(named: "AA_Edit_name")
            config.imagePlacement = .trailing  // 关键：将图片放置在文字后面
            config.imagePadding = 10           // 设置图片与文字的间距
            
            button = UIButton(configuration: config)
            button.tintColor = UIColor.black

        } else {
            button = UIButton.init(type: .custom)
            button.setTitle("你的昵称", for:.normal)
            // Fallback on earlier versions
        } // 或 .filled(), .tinted()
     
        button.setTitleColor(UIColor.black, for: .normal)
        
        return button
    }()
    
    private let tipsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("与其他用户交流时，您的个人资料将与您的消息一起发送。", for: .normal)
        btn.backgroundColor = UIColor.init(hexString: "#FFEDCF")
        btn.setTitleColor(UIColor.init(hexString: "#FF9900"), for: .normal)
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = .systemFont(ofSize: 11)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()
    
    
    let backEmailItem = AccountItemView(title: "备份邮箱", content: "")
    // 分割线
    let line2 = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        setupUI()
        setupConstraints()
        self.nicknameLabel.addTarget(self, action: #selector(didTapNickname), for: .touchUpInside)

        self.navigationItem.backButtonTitle = ""
        if let image = dcContext.getSelfAvatarImage() {
            self.avatarImageView.image = image
        }else{
          let image =  UIImage(named: "camera") ?? UIImage()
            self.avatarImageView.image = image

        }
        
        if let name = dcContext.displayname {
            self.nicknameLabel.setTitle(name, for: .normal)
            self.hasName = true
        }else{
            self.nicknameLabel.setTitle("您的昵称", for: .normal)
            self.hasName = false

        }
        
        if let addr = dcContext.addr {
            let api = iFBaseAPI.getRecoveryEmail(main_email: addr)
            HttpClient.shareInstance.request(target: api) {[weak self] data in
                
                guard let self = self else { return  }
                
                let decoder = JSONDecoder()
                let result = try? decoder.decode(RecoveryEmailModel.self, from: data)
                
                if let result = result,result.success == true,result.recovery_email.isEmpty == false{
                    
                    self.backEmailItem.updateText(text: result.recovery_email)
                    self.backEmailItem.isHidden = false
                    self.line2.isHidden = false
                    
                }else{
                    self.backEmailItem.isHidden = true
                    self.line2.isHidden = true


                }
                
             
            }

        }

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.addSubview(headerBackground)
        contentView.addSubview(mainStackView)
        
        // 构建个人资料各个部分
        setupProfileHeader()
        setupSignatureSection()
        setupAccountInfoSection()
        setupQRCodeSection()
        
        setupTapToDismiss()
        let tap = UITapGestureRecognizer.init()
        tap.addTarget(self, action: #selector(didClickAvatar))
        avatarImageView.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
        
        
        self.lastStandardAppearance = navigationController?.navigationBar.standardAppearance
        self.lastScrollEdgeAppearance = navigationController?.navigationBar.scrollEdgeAppearance
        self.lastCompactAppearance = navigationController?.navigationBar.compactAppearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // 保持你要求的沉浸式（背景透明）
       
        
        // --- 应用配置 ---
        self.navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    @objc func didClickAvatar(){
        print("avatarImageView:\(avatarImageView)")
        self.onAvatarTapped()
    }
    
    
    
    
    // 当点击“您的昵称”区域时调用
    @objc private func didTapNickname() {
        var name = ""
        if hasName {
            name = self.nicknameLabel.currentTitle ?? ""
        }
        
        self.showSystemChangeNameAlert(name: name)
    }
    
    @objc private func showSystemChangeNameAlert(name:String) {
        // 1. 创建 UIAlertController，样式选择 .alert
        let alert = UIAlertController(title: "修改昵称", message: "请输入您想使用的新昵称", preferredStyle: .alert)
        
        // 2. 添加输入框
        alert.addTextField { textField in
            textField.placeholder = "新昵称"
            textField.text = name // 默认显示当前昵称
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
        }
        
        // 3. “取消”按钮
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 4. “确定”按钮
        let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self?.updateNickname(newName)
            }
        }
        
        // 5. 修改确定按钮的颜色（使其符合你的橙色主题）
        confirmAction.setValue(UIColor.systemOrange, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        // 6. 弹出弹窗
        self.present(alert, animated: true, completion: nil)
    }

    private func updateNickname(_ name: String) {
        self.nicknameLabel.setTitle(name, for: .normal)
        self.hasName = true
        // 在这里可以执行 API 请求同步服务器数据
    }
    
    // MARK: - actions
    @objc func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc func doneButtonPressed() {
        dcContext.selfstatus = self.signatureView.getText()
        dcContext.displayname = self.nicknameLabel.currentTitle
        if let changeAvatar {
            AvatarHelper.saveSelfAvatarImage(dcContext: dcContext, image: changeAvatar)
        } else if deleteAvatar {
            dcContext.selfavatar = nil
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    private func enlargeAvatarPressed(_ action: UIAlertAction) {
        // temporarily save to file as PreviewController uses QLPreviewItem which does not accept UIImage
//        guard let image = avatarSelectionCell.badge.getImage() else { return }
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent("preview.png")
//        guard let imageData = image.pngData() else { return }
//        guard (try? imageData.write(to: url)) != nil else { return }
//
//        let previewController = PreviewController(dcContext: dcContext, type: .single(url))
//        previewController.customTitle = String.localized("pref_profile_photo")
//        navigationController?.pushViewController(previewController, animated: true)
    }

    private func galleryButtonPressed(_ action: UIAlertAction) {
        mediaPicker?.showGallery(allowCropping: true)
    }

    private func cameraButtonPressed(_ action: UIAlertAction) {
        mediaPicker?.showCamera(allowCropping: true, supportedMediaTypes: .photo)
    }

    private func deleteProfileIconPressed(_ action: UIAlertAction) {
        changeAvatar = nil
        deleteAvatar = true
//        avatarSelectionCell.setAvatar(image: nil)
        self.avatarImageView.image =  UIImage(named: "camera")
    }

    private func onAvatarTapped() {
        let alert = UIAlertController(title: String.localized("pref_profile_photo"), message: nil, preferredStyle: .safeActionSheet)
        if let image = dcContext.getSelfAvatarImage() {
            alert.addAction(UIAlertAction(title: String.localized("global_menu_view_desktop"), style: .default, handler: enlargeAvatarPressed(_:)))
        }
        alert.addAction(PhotoPickerAlertAction(title: String.localized("camera"), style: .default, handler: cameraButtonPressed(_:)))
        alert.addAction(PhotoPickerAlertAction(title: String.localized("gallery"), style: .default, handler: galleryButtonPressed(_:)))
        if let image = dcContext.getSelfAvatarImage() {
            alert.addAction(UIAlertAction(title: String.localized("delete"), style: .destructive, handler: deleteProfileIconPressed(_:)))
        }
        alert.addAction(UIAlertAction(title: String.localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func onImageSelected(image: UIImage) {
        changeAvatar = image
        deleteAvatar = false
        self.avatarImageView.image = image
//        avatarSelectionCell.setAvatar(image: image)
    }

    
    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    private func setupProfileHeader() {
        let container = UIView()
//        container.backgroundColor = .blue
        container.addSubview(self.tipsButton)
        
        self.tipsButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.bottom.equalTo(headerBackground.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.size.equalTo(88)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview()
        }
        
        mainStackView.addArrangedSubview(container)
        container.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
    }
    
    private func setupSignatureSection() {

        
        // 1. 标题
            let sectionTitle = createSectionTitle(title: "签名档", icon: "leaf.fill")
            mainStackView.addArrangedSubview(sectionTitle)
            
            // 2. 优化后的签名组件
        
        let text = dcContext.selfstatus ?? ""
        let signatureView = SignatureSectionView(text: text)
        self.signatureView = signatureView
            mainStackView.addArrangedSubview(signatureView)
            
            // 设置左右边距，使其与标题对齐
            signatureView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
            }
    }
    
    private func setupAccountInfoSection() {
        // 1. 创建标题栏
        let sectionTitle = createSectionTitle(title: "账号信息", icon: "person.text.rectangle")
        mainStackView.addArrangedSubview(sectionTitle)
        
        // 2. 创建白色背景卡片
        let cardContainer = UIView()
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 20
        // 添加阴影效果
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer.layer.shadowOpacity = 0.1
        cardContainer.layer.shadowRadius = 10
        
        mainStackView.addArrangedSubview(cardContainer)
        
        // 3. 创建卡片内部的 StackView
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 20
        cardContainer.addSubview(innerStack)
        
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        // 4. 添加具体的邮箱和链接项
        let emailItem = AccountItemView(title: "邮箱", content: dcContext.addr ?? "")
        
        // 分割线
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        line.snp.makeConstraints { make in make.height.equalTo(1) }
        
     
        line2.backgroundColor = UIColor(white: 0.9, alpha: 1)
        line2.snp.makeConstraints { make in make.height.equalTo(1) }
        
        
        var text:String = ""
        if let inviteLink = Utils.getInviteLink(context: dcContext, chatId: 0) {
            let url = DeltaChatLinkConverter.deltaChatToOpenPGP4FPR(inviteLink) ?? inviteLink
            text = url

        }
        
        let linkItem = AccountItemView(
            title: "邀请链接",
            content: text,
            actionTitle: "复制"
        )
        
        innerStack.addArrangedSubview(emailItem)
        innerStack.addArrangedSubview(line)
        innerStack.addArrangedSubview(backEmailItem)
        innerStack.addArrangedSubview(line2)
        innerStack.addArrangedSubview(linkItem)
        line2.isHidden = true
        backEmailItem.isHidden = true
    }
    

    
    private func setupQRCodeSection() {
        // 1. 标题部分
        let sectionTitle = createSectionTitle(title: "二维码", icon: "qrcode")
        mainStackView.addArrangedSubview(sectionTitle)
        
        // 2. 二维码容器卡片
        let qrCard = UIView()
        qrCard.backgroundColor = .white
        qrCard.layer.cornerRadius = 24
        
        // 优化阴影：使用更浅、更弥散的阴影
        qrCard.layer.shadowColor = UIColor.black.cgColor
        qrCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        qrCard.layer.shadowOpacity = 0.1
        qrCard.layer.shadowRadius = 15
        
        mainStackView.addArrangedSubview(qrCard)
        
        // 3. 二维码图片
        let qrImageView = UIImageView()
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.backgroundColor = .white // 确保背景干净
        
        qrCard.addSubview(qrImageView)
        
   
        if  let inviteLink = Utils.getInviteLink(context: dcContext, chatId: 0) {
            let url = DeltaChatLinkConverter.deltaChatToOpenPGP4FPR(inviteLink) ?? inviteLink
            
            // 使用示例
            let config = AdvancedQRCodeGenerator.QRCodeConfig(
                size: CGSize(width: 150, height: 150),
                correctionLevel: "L",
                foregroundColor: .black,
                backgroundColor: .white
          
            )

            let qrCodeImage = AdvancedQRCodeGenerator.generateQRCode(from: url, config: config)
            
            qrImageView.image = qrCodeImage
        }
        
       
        
        // 布局：给二维码图片留出适当的内边距 (Padding)
        qrImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(35) // 上下留白
            make.centerX.equalToSuperview()
            make.width.equalTo(qrImageView.snp.height) // 保持正方形
            make.width.equalToSuperview().multipliedBy(0.65) // 占卡片宽度的 65%
        }
    }
    
    private func createSectionTitle(title: String, icon: String) -> UIView {
        let view = UIView()
        let iconView = UIImageView(image: UIImage(systemName: icon))
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        
        view.addSubview(iconView)
        view.addSubview(label)
        
        iconView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        view.snp.makeConstraints { make in make.height.equalTo(30) }
        return view
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        headerBackground.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20) // 关键：撑开 ContentSize
        }
    }
}

import UIKit
import SnapKit

class AccountItemView: UIView {
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    init(title: String, content: String, actionTitle: String? = nil) {
        super.init(frame: .zero)
        setupUI(title: title, content: content, actionTitle: actionTitle)
    }
    
    func updateText(text:String){
        self.contentLabel.text = text
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(title: String, content: String, actionTitle: String?) {
        // 标题样式
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .black
        
        // 内容样式：改为灰色并支持自动换行
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .lightGray
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byCharWrapping
        
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        // 布局：标题在顶部
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        // 如果有“复制”按钮
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            addSubview(actionButton)
            
            actionButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel) // 按钮与标题水平居中对齐
                make.trailing.equalToSuperview()
            }
            
            // 内容在标题下方，并避开右侧按钮区域（如果需要的话，通常内容可以占满全宽）
            contentLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        } else {
            // 没有按钮的情况（如邮箱行）
            // 备注：如果邮箱也要上下排，按此逻辑；如果邮箱要左右排，可以加判断。
            // 按照您的要求，目前统一为上下排列以支持长内容。
            contentLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    @objc private func handleAction() {
        // 这里可以加上之前讨论的弹窗或者吐司提示
        print("已复制内容到剪贴板")
        UIPasteboard.general.string = contentLabel.text
        ProgressHUD.succeed("复制成功")
    }
}



class SignatureSectionView: UIView, UITextViewDelegate {
    
    // 内部容器：用于实现灰色背景和圆角
    private let containerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    
    let text:String
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
    
    init(text:String) {
        self.text = text
        super.init(frame: CGRect.zero)
        setupUI()
    }
        
    
    
    
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        // 1. 配置容器
        addSubview(containerView)
        containerView.backgroundColor = .white // 浅灰色背景
        containerView.layer.cornerRadius = 20
//        containerView.layer.masksToBounds = true
        
        // 添加阴影效果
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 10
        
        // 2. 配置 TextView
        containerView.addSubview(textView)
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .black
        textView.delegate = self
        textView.isScrollEnabled = false // 关键：自适应高度
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.text = self.text
        
        // 3. 配置占位符
        textView.addSubview(placeholderLabel)
        placeholderLabel.text = "写点什么吧~"
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = .lightGray
        
        // --- SnapKit 布局 ---
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 填满当前 View
            make.height.greaterThanOrEqualTo(80) // 设置最小高度
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(5)
        }
        
        self.textViewDidChange(self.textView)

    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // 触发自适应高度调整
        UIView.performWithoutAnimation {
            self.invalidateIntrinsicContentSize()
            (self.superview as? UIStackView)?.layoutIfNeeded()
        }
    }
    
    func getText()->String{
        return self.textView.text ?? ""
    }
}
