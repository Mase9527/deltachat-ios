//
//  SelfProfileViewQRCodeCell.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/7.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

class SelfProfileViewQRCodeCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
   
    }
    
    var dcContext:DcContext?
    
    init(dcContext:DcContext) {
        self.dcContext = dcContext
        super.init(style: .default, reuseIdentifier: nil)
 
        setupSubviews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        let imageView = UIImageView()
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(30)
            make.height.equalTo(250)
        }
        imageView.backgroundColor = .white
 
        imageView.contentMode = .scaleAspectFit

        if let dcContext = self.dcContext,  let inviteLink = Utils.getInviteLink(context: dcContext, chatId: 0) {
            let url = DeltaChatLinkConverter.deltaChatToOpenPGP4FPR(inviteLink) ?? inviteLink
            
            // 使用示例
            let config = AdvancedQRCodeGenerator.QRCodeConfig(
                size: CGSize(width: 300, height: 300),
                correctionLevel: "L",
                foregroundColor: .black,
                backgroundColor: .white
          
            )

            let qrCodeImage = AdvancedQRCodeGenerator.generateQRCode(from: url, config: config)
            
            imageView.image = qrCodeImage
        }
        
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
