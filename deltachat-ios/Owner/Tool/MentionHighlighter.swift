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
    
    // MARK: - 检测 @
    func detectMentions(in text: String, cursorPosition: Int) -> (shouldShow: Bool, searchText: String?, range: NSRange?) {
        // 获取光标前一个字符
        guard cursorPosition > 0 else { return (false, nil, nil) }
        
        let index = text.index(text.startIndex, offsetBy: cursorPosition)
        let beforeCursor = String(text[..<index])
        
        // 查找最后一个 @
        guard let atRange = beforeCursor.range(of: "@", options: .backwards) else {
            return (false, nil, nil)
        }
        
        // 检查 @ 后是否有空格或换行
        let afterAt = String(beforeCursor[atRange.upperBound...])
        
        // 如果 @ 后面紧跟着空格或换行，或者已经在输入其他内容（比如已经在输入联系人），不显示
        if afterAt.isEmpty || afterAt.first?.isWhitespace == true {
            return (true, nil, nil)
        }
        
        // 提取搜索文本（@后面的内容）
        let searchStartIndex = atRange.upperBound
        let searchEndIndex = beforeCursor.endIndex
        
        // 查找搜索文本结束位置（遇到空格或结尾）
        var searchText = String(beforeCursor[searchStartIndex..<searchEndIndex])
        
        // 如果搜索文本中包含空格，只取第一个单词
        if let spaceRange = searchText.range(of: " ") {
            searchText = String(searchText[..<spaceRange.lowerBound])
        }
        
        // 计算范围
        let nsRange = NSRange(atRange, in: beforeCursor)
        
        return (false, searchText, nsRange)
    }
    
    // MARK: - 获取所有 @ 提及
    func extractMentions(from text: String) -> [MentionRange] {
        guard let regex = regex else { return [] }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var mentions: [MentionRange] = []
        
        for match in matches {
            let range = match.range
            let mentionText = nsString.substring(with: range)
            
            // 移除 @ 符号
            let searchText = String(mentionText.dropFirst())
            
            // 这里可以匹配联系人，暂时返回空
            mentions.append(MentionRange(range: range,
                                         contact: OwnerContact(id: "", name: searchText),
                                         text: mentionText))
        }
        
        return mentions
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
}
