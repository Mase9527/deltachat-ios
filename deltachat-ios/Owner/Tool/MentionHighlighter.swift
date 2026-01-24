import Foundation

struct MentionHighlighter {

    /**
     * 转义正则表达式中的特殊字符
     */
    static func escapeRegExp(_ string: String) -> String {
        return NSRegularExpression.escapedPattern(for: string)
    }

    /**
     * 创建用于检测@提及的正则表达式
     * 如果提供name参数，则检测特定名称的提及
     * 否则检测任何@提及
     */
    static func createMentionRegex(name: String? = nil) -> NSRegularExpression? {
        let pattern: String
        var options: NSRegularExpression.Options = []

        if let nameToFind = name {
            // 如果提供了名称，则创建一个正则表达式来匹配特定的@name
            // (?=[\s,.!?;:]|$) 是一个正向预查，确保提及后面是空格、标点符号或字符串结尾
            pattern = "(^|\\s)@\(escapeRegExp(nameToFind))(?=[\\s,.!?;:]|$)"
            options = .caseInsensitive // 对应于 'i' 标志
        } else {
            // 否则，创建一个正则表达式来匹配任何@提及
            // ([^\s,.!?;:]+) 捕获不包含空格或标点符号的用户名
            pattern = "(^|\\s)@([^\\s,.!?;:]+)(?=[\\s,.!?;:]|$)"
        }

        do {
            return try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            print("Error creating regex: \(error)")
            return nil
        }
    }

    /**
     * 高亮显示文本中的@提及
     */
    static func highlightMentions(in text: String) -> String {
        // 创建一个用于匹配任何提及的正则表达式
        guard let mentionRegex = createMentionRegex() else {
            return text
        }

        let range = NSRange(text.startIndex..., in: text)
        
        // 使用替换模板来包裹提及
        // $1 对应于提及前的空格或字符串开头 (^|\s)
        // $2 对应于用户名 ([^\s,.!?;:]+)
        let template = "$1<span class=\"mention\">@$2</span>"
        
        return mentionRegex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: template)
    }
}

// 示例用法:
/*
let text = "Hello @john.doe, how are you? Contact @jane-doe."
let highlightedText = MentionHighlighter.highlightMentions(in: text)
print(highlightedText) 
// 输出: Hello <span class="mention">@john.doe</span>, how are you? Contact <span class="mention">@jane-doe</span>.

if let johnRegex = MentionHighlighter.createMentionRegex(name: "john.doe") {
    let matches = johnRegex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
    if !matches.isEmpty {
        print("Found a mention for John Doe.")
    }
}
*/

// MARK: - 联系人模型
struct OwnerContact: Equatable {
    let id: String
    let name: String
    
    static func == (lhs: OwnerContact, rhs: OwnerContact) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - @ 提及范围
struct MentionRange {
    let range: NSRange
    let contact: OwnerContact
    let text: String // 原始@文本，如@张三
}

// MARK: - @ 检测器
class MentionDetector {
    
    // MARK: - 正则表达式
    private let atPattern = "@[^\\s@]+"
    private let atFullPattern = "@([^\\s@]+)(?:\\s|$)"
    private var regex: NSRegularExpression?
    
    static let shared = MentionDetector()
    
    var currentContact:OwnerContact?
    
    // MARK: - 初始化
    init() {
        do {
            regex = try NSRegularExpression(pattern: atPattern, options: [])
        } catch {
            print("正则表达式初始化失败: \(error)")
        }
    }
    
  
    
    
     func shouldTriggerMention(at index: Int, in text: NSString) -> Bool {
        // 如果 @ 是第一个字符，直接允许
        if index == 0 { return true }
        
        // 获取 @ 前一个字符
        let previousChar = text.substring(with: NSRange(location: index - 1, length: 1))
        
        // 触发条件：前一个字符是 空格、制表符、换行符 或 某些特定标点
        let allowedPrefixSet = CharacterSet.whitespacesAndNewlines
        
        return previousChar.rangeOfCharacter(from: allowedPrefixSet) != nil
    }

 
    
    // MARK: - 检查文本是否包含 @
    func hasAtSymbol(in text: String) -> Bool {
        return text.contains("@")
    }
    
    // MARK: - 插入 @ 提及
    func insertMention(in text: String, at cursorPosition: Int, contact: OwnerContact) -> (newText: String, newCursorPosition: Int) {
        var text = text
        let atRange = findAtRange(in: text, cursorPosition: cursorPosition)
        
        if let range = atRange {
            // 替换 @搜索文本 为 @联系人姓名
            let mentionText = "@\(contact.name) "
            text = (text as NSString).replacingCharacters(in: range, with: mentionText)
            
            // 计算新光标位置
            let newPosition = range.location + mentionText.count
            return (text, newPosition)
        }
        
        // 如果没有找到 @ 范围，直接在当前位置插入
        let mentionText = "@\(contact.name) "
        let insertIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        text.insert(contentsOf: mentionText, at: insertIndex)
        
        return (text, cursorPosition + mentionText.count)
    }
    
    private func findAtRange(in text: String, cursorPosition: Int) -> NSRange? {
        guard cursorPosition > 0 else { return nil }
        
        let nsString = text as NSString
        let beforeCursor = nsString.substring(to: cursorPosition)
        
        // 查找最后一个 @
        guard let atRange = beforeCursor.range(of: "@", options: .backwards) else {
            return nil
        }
        
        // 从 @ 位置到光标位置
        let start = atRange.lowerBound.utf16Offset(in: beforeCursor)
        let length = cursorPosition - start
        
        return NSRange(location: start, length: length)
    }
    
    
    // MARK: - 插入 Mention
    func insertMention(userName: String, userId: String,textView:UITextView) {
        let mentionString = "@\(userName) "
        let attrs: [NSAttributedString.Key: Any] = [
            .font: textView.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
            .mention: userId
        ]
        
        let attributedMention = NSAttributedString(string: mentionString, attributes: attrs)
        let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        let selectedRange = textView.selectedRange
        if selectedRange.location > 0 {
            let replaceRange = NSRange(location: selectedRange.location - 1, length: 1)
            mutableText.replaceCharacters(in: replaceRange, with: attributedMention)
            
            textView.attributedText = mutableText
            
            // 1. 设置新的光标位置
            let newLocation = replaceRange.location + attributedMention.length
            textView.selectedRange = NSRange(location: newLocation, length: 0)
            
            // 2. 立即重置后续输入的属性
            let resetAttrs: [NSAttributedString.Key: Any] = [
                .font: textView.font ?? UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label // 恢复为黑色
            ]
            textView.typingAttributes = resetAttrs
        }
        
        textView.delegate?.textViewDidChange?(textView)
    }
    
    
    // 2. 拦截删除：实现整块删除逻辑
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // 如果是删除操作 (text 为空)
            if text.isEmpty && range.length > 0 {
                let attrText = textView.attributedText
                var mentionRange = NSRange()
                
                // 检查被删除的区域是否包含 mention 属性
                // 注意检查 range.location，即光标左侧的字符
                if range.location < attrText!.length,
                   let _ = attrText?.attribute(.mention, at: range.location, effectiveRange: &mentionRange) {
                    
                    let newText = NSMutableAttributedString(attributedString: attrText!)
                    newText.deleteCharacters(in: mentionRange)
                    textView.attributedText = newText
                    
                    // 设置光标位置到删除后的地方
                    textView.selectedRange = NSRange(location: mentionRange.location, length: 0)
                    
                    // 通知内容改变
                    textView.delegate?.textViewDidChange?(textView)
                    return false
                }
            }
            return true
        }
   
    
    func getExportString(textView:UITextView) -> String {
        let fullText = textView.attributedText ?? NSAttributedString()
        var resultString = ""
        
        // 遍历整个属性字符串
        fullText.enumerateAttributes(in: NSRange(location: 0, length: fullText.length), options: []) { attrs, range, _ in
            
            // 获取当前片段的原始文本（例如 "@小明 " 或 "内容"）
            let substring = (fullText.string as NSString).substring(with: range)
            
            if let userId = attrs[.mention] as? String {
                // 微信格式通常不包含末尾用于隔断的空格，我们处理一下
                let mentionText = substring.trimmingCharacters(in: .whitespaces)
                
                // 构造 XML 格式：<mention uin="123">@小明</mention>
                let mentionTag = "<mention uin=\"\(userId)\">\(mentionText)</mention>"
                
                resultString += mentionTag
                
                // 如果原始子串末尾有空格，把空格加回到标签外面，保证排版一致
                if substring.hasSuffix(" ") {
                    resultString += " "
                }
            } else {
                // 普通文本直接拼接
                resultString += substring
            }
        }
        return resultString
    }
    
    func importFrom(xmlString: String,textView:UITextView) {
        // 1. 定义匹配标签的正则表达式
        // 匹配 <mention uin="xxx">@xxx</mention>
        let pattern = "<mention uin=\"([^\"]+)\">([^<]+)</mention>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let attributedResult = NSMutableAttributedString()
        let nsString = xmlString as NSString
        var lastIndex = 0
        
        // 2. 查找所有匹配项
        let matches = regex?.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for match in matches {
            // a. 处理标签之前的普通文本
            let plainTextRange = NSRange(location: lastIndex, length: match.range.location - lastIndex)
            if plainTextRange.length > 0 {
                let plainString = nsString.substring(with: plainTextRange)
                attributedResult.append(NSAttributedString(string: plainString, attributes: [
                    .font: textView.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ]))
            }
            
            // b. 提取 uin 和 用户名
            let uinRange = match.range(at: 1)
            let nameRange = match.range(at: 2)
            
            let uin = nsString.substring(with: uinRange)
            let name = nsString.substring(with: nameRange)
            
            // c. 构造带属性的 Mention 块
            // 注意：这里为了保持输入体验，通常会在还原时补一个空格（如果原始 XML 里后面没空格的话）
            let mentionString = "\(name) "
            let attrs: [NSAttributedString.Key: Any] = [
                .font: textView.font ?? UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.systemBlue,
                .mention: uin
            ]
            attributedResult.append(NSAttributedString(string: mentionString, attributes: attrs))
            
            lastIndex = match.range.location + match.range.length
        }
        
        // 3. 处理最后一个标签之后的剩余文本
        if lastIndex < nsString.length {
            let remainingText = nsString.substring(from: lastIndex)
            attributedResult.append(NSAttributedString(string: remainingText, attributes: [
                .font: textView.font ?? UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]))
        }
        
        // 4. 更新 TextView
        textView.attributedText = attributedResult
        
        // 在 importFrom 末尾添加
        textView.typingAttributes = [
            .font: textView.font ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
    }
    
    // 将此方法放在 MessageLabel 外部或作为工具方法
     func parseXMLToMention(_ input: NSAttributedString, mentionAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let pattern = "<mention uin=\"([^\"]+)\">([^<]+)</mention>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let mutableResult = NSMutableAttributedString(attributedString: input)
        let xmlString = mutableResult.string as NSString
        let matches = regex?.matches(in: mutableResult.string, options: [], range: NSRange(location: 0, length: xmlString.length)) ?? []
        
        // 从后往前替换，保证 Range 不失效
        for match in matches.reversed() {
            let uin = xmlString.substring(with: match.range(at: 1))
            let name = xmlString.substring(with: match.range(at: 2))
            
            var attrs = mutableResult.attributes(at: match.range.location, effectiveRange: nil)
            // 注入识别 ID 和样式
            attrs[.mention] = uin
            mentionAttributes.forEach { attrs[$0.key] = $0.value }
            
            let replacement = NSAttributedString(string: name, attributes: attrs)
            mutableResult.replaceCharacters(in: match.range, with: replacement)
        }
        return mutableResult
    }
    
    func stripMentionTags(from xmlString: String) -> String {
        // 正则逻辑：匹配 <mention...> 和 </mention>
        // [^>] 表示匹配除了 > 之外的所有字符
        let pattern = "<mention [^>]*>([^<]+)</mention>"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return xmlString
        }
        
        let nsString = xmlString as NSString
        let mutableString = NSMutableString(string: xmlString)
        
        // 从后往前替换，防止 Range 偏移
        let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches.reversed() {
            // match.range(at: 1) 是 ([^<]+) 捕获的内容，即 "@小明"
            let nameContent = nsString.substring(with: match.range(at: 1))
            mutableString.replaceCharacters(in: match.range, with: nameContent)
        }
        
        return mutableString as String
    }
}







