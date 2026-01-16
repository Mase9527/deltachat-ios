//
//  LongImageViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/14.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

import UIKit
import SnapKit
import DcCore

class LongImageViewController: AABaseViewController {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
   let provider: MailProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayImage(named: provider.longImageName) // 替换为你的图片名
    }
    
    init(provider: MailProvider) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        setupNavigationBar()
        
        view.backgroundColor = DcColors.defaultBackgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
//        scrollView.backgroundColor = .green
        // 基础布局：ScrollView 填满全屏
        scrollView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.leading.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.trailing.equalToSuperview().offset(-10)
        }

        // 初始 ImageView 布局：锁定左右，连接顶部
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // 宽度固定为屏幕宽
        }
    }
    
    private func setupNavigationBar() {
        // 自定义导航栏左侧
        let leftView = UIView()
        let logo = UIImageView(image: UIImage(named: "dc_logo")) // 替换为你的猫咪图标
        let titleLabel = UILabel()
        titleLabel.text = provider.name
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

    private func displayImage(named name: String) {
        guard let image = UIImage(named: name) else { return }
        imageView.image = image

        // 1. 计算图片比例 (Height / Width)
        let imageRatio = image.size.height / image.size.width

        // 2. 根据比例更新高度约束
        imageView.snp.makeConstraints { make in
            // 计算出的高度 = 屏幕宽度 * 比例
            make.height.equalTo(imageView.snp.width).multipliedBy(imageRatio)
            // 3. 必须连接到底部，ScrollView 才能计算滚动高度
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
        }
    }
}
