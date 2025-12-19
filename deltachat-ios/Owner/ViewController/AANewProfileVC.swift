//
//  AANewProfileVC.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/24.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit
import DcCore

class AANewProfileVC: UIViewController {

    
    var onSignUp: VoidFunction?
    var onLogIn: VoidFunction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = DcColors.defaultBackgroundColor
        
        
        let imageView = UIImageView(image: UIImage(named: "AA_Login_Logo"))

        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
            make.centerX.equalToSuperview()
        }

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Welcome to AA"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.top.equalTo(imageView.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }

        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = String.localized("welcome_chat_over_email")
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // Create New Profile Button
        let createProfileButton = UIButton(type: .system)
        createProfileButton.setTitle(String.localized("onboarding_create_instant_account"), for: .normal)
        createProfileButton.backgroundColor = DcColors.primary
        createProfileButton.setTitleColor(.white, for: .normal)
        createProfileButton.layer.cornerRadius = 8
        view.addSubview(createProfileButton)
        createProfileButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
//            make.width.equalTo(200)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }

        // Already Have a Profile Button
        let existingProfileButton = UIButton(type: .system)
        existingProfileButton.setTitle(String.localized("onboarding_alternative_logins"), for: .normal)
        existingProfileButton.setTitleColor(DcColors.text1, for: .normal)
//        existingProfileButton.layer.borderWidth = 1
//        existingProfileButton.layer.borderColor = UIColor.systemOrange.cgColor
        existingProfileButton.layer.cornerRadius = 8
        existingProfileButton.backgroundColor = .white

        view.addSubview(existingProfileButton)
        existingProfileButton.snp.makeConstraints { make in
            make.top.equalTo(createProfileButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
//            make.width.equalTo(200)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
        
        createProfileButton.addTarget(self, action: #selector(signUpButtonPressed(_:)), for: .touchUpInside)
        existingProfileButton.addTarget(self, action: #selector(logInButtonPressed(_:)), for: .touchUpInside)

    }
    
    // MARK: - actions
    @objc private func signUpButtonPressed(_ sender: UIButton) {
        onSignUp?()
    }
    
    @objc private func logInButtonPressed(_ sender: UIButton) {
        onLogIn?()
    }
}
