import Foundation
import DcCore
import UIKit

class TextMessageCell: BaseMessageCell, ReusableCell {

    static let reuseIdentifier = "TextMessageCell"

    override func setupSubviews() {
        super.setupSubviews()
        mainContentView.addArrangedSubview(messageLabel)
        messageLabel.paddingLeading = 12
        messageLabel.paddingTrailing = 12
    }

    override func update(dcContext: DcContext, msg: DcMsg, messageStyle: UIRectCorner, showAvatar: Bool, showName: Bool, searchText: String?, highlight: Bool) {
        if msg.type == DC_MSG_CALL {
            msg.text = "📞 " + (msg.text ?? "")
        }

        messageLabel.text = msg.text

        super.update(dcContext: dcContext,
                     msg: msg,
                     messageStyle: messageStyle,
                     showAvatar: showAvatar,
                     showName: showName,
                     searchText: searchText,
                     highlight: highlight)
        
        if   msg.type == DC_MSG_VCARD,
              let file = msg.file,
             let vcard = dcContext.parseVcard(path: file)?.first,let attr = messageLabel.attributedText{
            
            let motionName = "@\(vcard.displayName)"
            
            self.messageLabel.attributedText = self.colorMentionInText(text: attr, mention: motionName)
        }
    }
    
    // MARK: - 方法1：使用 NSRange 直接修改
        func colorMentionInText(
           text: NSAttributedString,
           mention: String,
           color: UIColor = UIColor.systemBlue
       ) -> NSAttributedString {
           // 将普通字符串转换为 NSAttributedString
           let attributedString = NSMutableAttributedString.init(attributedString: text)
           
           // 查找提及的范围
           let nsText = text.string as NSString
           let range = nsText.range(of: mention)
           
           // 如果找到提及，设置颜色
           if range.location != NSNotFound {
               attributedString.addAttributes([
                   .foregroundColor: color,
                   // 可以添加更多属性
                   // .font: UIFont.boldSystemFont(ofSize: 16)
               ], range: range)
           }
           
           return attributedString
       }

}
