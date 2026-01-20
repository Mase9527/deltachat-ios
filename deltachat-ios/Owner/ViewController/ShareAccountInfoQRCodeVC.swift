//
//  ShareAccountInfoQRCodeVC.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/5.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore
import SDWebImageSVGKitPlugin

class ShareAccountInfoQRCodeVC: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dcContext: DcContext
    let dcAccounts: DcAccounts
    
    var  imageView:UIImageView?
    
    var qrCode:String = ""
    var key:String = ""

    var copyButton:UIButton?
    
    var textView:UITextView = UITextView()
    
    var textContentView:UIView = UIView()

    init(dcContext: DcContext, dcAccounts: DcAccounts,qrCode:String,key:String) {
        self.dcContext = dcContext
        self.dcAccounts = dcAccounts
        self.qrCode = qrCode
        self.key = key

        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "导出密钥"
        let imageView = UIImageView()

        self.view.addSubview(imageView)
        

        
   
        // 使用示例
        let config = AdvancedQRCodeGenerator.QRCodeConfig(
            size: CGSize(width: 300, height: 300),
            correctionLevel: "L",
            foregroundColor: .black,
            backgroundColor: .white
      
        )

        let qrCode = AdvancedQRCodeGenerator.generateQRCode(from: self.key, config: config)
        
       imageView.image = qrCode
        imageView.contentMode = .scaleAspectFit
        
        imageView.backgroundColor = .white
        
        self.imageView = imageView;
        
        
        let button = UIButton(type: .custom)
        button.setTitle("复制文本到剪切板", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        self.copyButton = button
        self.view.addSubview(button)
        
        self.view.addSubview(self.textView)
        
        
        self.view.addSubview(self.textContentView)
        
        
        let label = UILabel()
        label.text = self.key
        label.numberOfLines = 0;
        label.font = .systemFont(ofSize: 15)
        self.textContentView.backgroundColor = .white
        self.textContentView.layer.cornerRadius = 15
        self.textContentView.clipsToBounds = true
        
        self.textContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.view.snp.topMargin).offset(20)
          
        }
        
        self.textContentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }

        button.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        self.textView.isHidden = true
        self.textView.isEditable = false
        self.textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        self.textView.backgroundColor = .white
        self.textView.layer.cornerRadius = 15
        self.textView.clipsToBounds = true
        self.textView.text = self.key;
        self.textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.height.equalTo(450)
        }
        self.copyButton?.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(250)
            make.top.equalTo(self.textContentView.snp.bottom).offset(25)
        }
        
        self.view.backgroundColor = .systemGroupedBackground
        
       let ok = PGPVerifier.verifyEmail("poi@aa1234.com", inKey: self.key)
        
        print("PGPVerifier:\(ok)")
        
    }
    @objc func copyAction(){
        let textToCopy = self.qrCode
        // 获取系统剪贴板
        let pasteboard = UIPasteboard.general
        // 将文本设置到剪贴板
        pasteboard.string = textToCopy
        
                        ProgressHUD.succeed("复制成功",delay: 3)
    }
    override func viewDidLayoutSubviews() {
        
        let bottomSafeArea = view.safeAreaInsets.bottom
        let topSafeArea = view.safeAreaInsets.top
        let frame = CGRectMake((self.view.bounds.width - 300)/2.0, 50+topSafeArea, 300, 300)
        self.imageView?.frame = frame
//        
//        self.copyButton?.frame = CGRect(x: 50, y: (self.imageView?.frame.maxY ?? 0) + 40, width: self.view.bounds.width - 100, height: 40)
    }


    // MARK: - lifecycle
    func getQrImage(svg: String?) -> UIImage? {
        guard let svg else { return nil }

        let svgData = svg.data(using: .utf8)
        let image = SDImageSVGKCoder.shared.decodedImage(with: svgData, options: [:])
        return image
    }
}
