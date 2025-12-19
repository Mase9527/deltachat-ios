//
//  AccountInfoPopupViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/2.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

class AccountInfoPopupViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var xButton: UIButton!
    
    @IBOutlet weak var qcCodeImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var copyButton: UIButton!
    
    private let dcContext: DcContext
    private let chatId: Int

    
    init(dcContext: DcContext, chatId: Int = 0, qrCodeHint: String = "") {
        self.dcContext = dcContext
        self.chatId = chatId
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
           super.viewDidLoad()
           self.contentView.layer.cornerRadius = 15;
           self.contentView.clipsToBounds = true
           // 设置整个视图的背景为半透明黑色
           view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.copyButton.layer.cornerRadius = 8;
        self.closeButton.layer.cornerRadius = 8;
        closeButton.clipsToBounds = true
        copyButton.clipsToBounds = true
          
        setupQRCodeImage()
       }
    
    func setupQRCodeImage(){
        if let inviteLink = Utils.getInviteLink(context: dcContext, chatId: 0) {
            let url = DeltaChatLinkConverter.deltaChatToOpenPGP4FPR(inviteLink) ?? inviteLink
            
            // 使用示例
            let config = AdvancedQRCodeGenerator.QRCodeConfig(
                size: CGSize(width: 300, height: 300),
                correctionLevel: "L",
                foregroundColor: .black,
                backgroundColor: .white
          
            )

            let qrCodeImage = AdvancedQRCodeGenerator.generateQRCode(from: url, config: config)
            
            qcCodeImageView.image = qrCodeImage
        }
    }
       @objc func closeButtonTapped() {
           dismiss(animated: true, completion: nil)
       }
    @IBAction func didClickCopyButton(_ sender: UIButton) {
        
        let inviteLink = Utils.getInviteLink(context: dcContext, chatId: chatId)
        let url = DeltaChatLinkConverter.deltaChatToOpenPGP4FPR(inviteLink ?? "") ?? inviteLink

        guard let urlStr = url, let inviteLinkURL = URL(string: urlStr) else { return }
        UIPasteboard.general.string = urlStr;
        ProgressHUD.succeed("复制成功")
    }
    @IBAction func didClickCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickXButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
