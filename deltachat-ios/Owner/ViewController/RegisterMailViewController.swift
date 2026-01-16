//
//  RegisterMailViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/14.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import DcCore

struct MailProvider {
    let name: String
    let longImageName: String
    let logoName: String
}

class RegisterMailViewController: AABaseViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let dcAccounts: DcAccounts
    private let dcContext: DcContext


    // 总容器 StackView
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        return sv
    }()
    
    init(dcAccounts: DcAccounts) {
        self.dcAccounts = dcAccounts
        self.dcContext = dcAccounts.getSelected()

 

        super.init(nibName: nil, bundle: nil)


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        // 自定义导航栏左侧
        let leftView = UIView()
        let logo = UIImageView(image: UIImage(named: "dc_logo")) // 替换为你的猫咪图标
        let titleLabel = UILabel()
        titleLabel.text = "AAmail"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        leftView.addSubview(logo)
        leftView.addSubview(titleLabel)
        logo.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(logo.snp.right).offset(8)
            make.right.centerY.equalToSuperview()
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftView)
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        // 右侧关闭按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
    }

    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 245/255, alpha: 1.0)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        // 添加两个卡片
        mainStackView.addArrangedSubview(createTopExperienceCard())
        mainStackView.addArrangedSubview(createOldSystemCard())
    }

    
    
    
    // MARK: - 创建顶部卡片
    private func createTopExperienceCard() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        
        let logoImageView = UIImageView(image: UIImage(named: "topEmail_logo")) // 对应中间的大 Logo
        logoImageView.contentMode = .scaleAspectFit
        
        let descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        let attrString = NSMutableAttributedString(string: "支持视频/语音/实时通话\n", attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .bold)])
        attrString.append(NSAttributedString(string: "直接生成电子邮箱账号", attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .bold), .foregroundColor: UIColor.orange]))
        descLabel.attributedText = attrString
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("立即体验", for: .normal)
        actionButton.backgroundColor = .systemOrange
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        actionButton.layer.cornerRadius = 25
        actionButton.addTarget(self, action: #selector(goToRegiserAction), for: .touchUpInside)
        
        [logoImageView, descLabel, actionButton].forEach { container.addSubview($0) }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        return container
    }

    // MARK: - 创建底部卡片
    private func createOldSystemCard() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.text = "老牌电子邮箱系统"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subLabel = UILabel()
        subLabel.text = "需要设置POP/IMAP 转发，大部分免费电子邮箱已经不支持第三方登录，需要使用老牌电子邮箱请自行尝试或者用付费电子邮箱。"
        subLabel.numberOfLines = 0
        subLabel.textColor = .gray
        subLabel.font = .systemFont(ofSize: 14)
        
        let sohu = MailProvider(name: "搜狐闪电邮箱", longImageName: "souhu_guide", logoName: "sohu_logo")
            let sohuItem = createListItem(provider: sohu) { [weak self] in
                self?.navigateToDetail(for: sohu)
            }
            
            let qq = MailProvider(name: "QQ邮箱", longImageName: "qq_guide", logoName: "qq_logo")
            let qqItem = createListItem(provider: qq) { [weak self] in
                self?.navigateToDetail(for: qq)
            }
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        let line2 = UIView()
        line2.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        [titleLabel, subLabel, line, sohuItem,line2, qqItem].forEach { container.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.right.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        sohuItem.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        line2.snp.makeConstraints { make in
            make.top.equalTo(sohuItem.snp.bottom).offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        qqItem.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
   
        
        return container
    }
    
    // MARK: - 列表项辅助方法
    private func createListItem(logoName: String, title: String, sub: String) -> UIView {
        let view = UIView()
        let logo = UIImageView(image: UIImage(named: logoName))
        logo.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.text = title
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        let subLabel = UILabel()
        subLabel.text = sub
        subLabel.font = .systemFont(ofSize: 12)
        subLabel.textColor = .systemBlue
        
        let arrow = UIButton(type: .system)
        arrow.setTitle("查看详情 ▶", for: .normal)
        arrow.setTitleColor(.black, for: .normal)
        arrow.titleLabel?.font = .systemFont(ofSize: 12)
        
        [logo, nameLabel, subLabel, arrow].forEach { view.addSubview($0) }
        
        logo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(logo.snp.right).offset(12)
            make.top.equalToSuperview().offset(15)
        }
        
        subLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        arrow.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        return view
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    // 在 RegisterMailViewController 内部添加
    private func createListItem(provider: MailProvider, action: @escaping () -> Void) -> UIView {
        let view = UIControl() // 使用 UIControl 自带点击态
        view.backgroundColor = .white
        
        // 点击反馈效果
        view.addTarget(self, action: #selector(viewTapped(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(viewReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // 绑定点击回调
        let tapAction = UIAction { _ in action() }
        view.addAction(tapAction, for: .touchUpInside)

        let logo = UIImageView(image: UIImage(named: provider.logoName))
        logo.contentMode = .scaleAspectFit
        
        let nameLabel = UILabel()
        nameLabel.text = provider.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        let subLabel = UILabel()
//        subLabel.text = provider.url
        subLabel.font = .systemFont(ofSize: 12)
        subLabel.textColor = .systemBlue
        
        let arrowLabel = UILabel()
        arrowLabel.text = "查看详情 ▶"
        arrowLabel.font = .systemFont(ofSize: 12)
        arrowLabel.textColor = .black
        
//        [logo, nameLabel, subLabel, arrowLabel].forEach { view.addSubview($0) }
        
        [logo, arrowLabel].forEach { view.addSubview($0) }

        
        logo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
//            make.size.equalTo(40)
        }
        
//        nameLabel.snp.makeConstraints { make in
//            make.left.equalTo(logo.snp.right).offset(12)
//            make.top.equalToSuperview().offset(15)
//        }
//        
//        subLabel.snp.makeConstraints { make in
//            make.left.equalTo(nameLabel)
//            make.top.equalTo(nameLabel.snp.bottom).offset(2)
//            make.bottom.equalToSuperview().offset(-15)
//        }
        
        arrowLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        return view
    }

    // 简单的点击视觉反馈
    @objc private func viewTapped(_ sender: UIControl) {
        sender.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }

    @objc private func viewReleased(_ sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            sender.backgroundColor = .white
        }
    }
    
    @objc func goToRegiserAction(){
        let registerVC = RegisterViewController(dcAccounts: self.dcAccounts)
        self.navigationController?.pushViewController(registerVC, animated: true)

    }
    
    // 跳转逻辑
    private func navigateToDetail(for provider: MailProvider) {
        print("跳转到 \(provider.name) 的详情页")
        let detailVC = LongImageViewController.init(provider: provider)
        self.navigationController?.pushViewController(detailVC, animated: true)
        // 示例：跳转到一个 WebView 或自定义详情页
//         let detailVC = AALoginMainVC()
//         self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
