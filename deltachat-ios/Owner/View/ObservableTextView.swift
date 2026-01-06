//
//  ObservableTextView.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/6.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

class ObservableTextView: UITextView {
    
    static func chatStyle()->ObservableTextView{
      let  textView = ObservableTextView.init();
        textView.font = UIFont.systemFont(ofSize: 17.5);
        textView.returnKeyType = .send;
        textView.scrollsToTop = false;
        textView.textAlignment = .left;
        textView.layer.cornerRadius = 6.0;
        //top, left, bottom, right
        textView.textContainerInset = .init(top: 10, left: 8, bottom: 10, right: 8);
        //如果我设置了left边距，换行的时候，xcode会弹出提示：requesting caretRectForPosition: while the NSTextStorage has oustanding changes . 但是实际运行没任何影响
        //如果把left（第2、4个参数）设置为0，就不会有警告。原因不明
        
        textView.enablesReturnKeyAutomatically = true; // UITextView内部判断send按钮是否可以用
        return textView
    }

    // 定义一个闭包，在删除键按下时触发
        var onDeleteBackward: (() -> Void)?

        override func deleteBackward() {
            // 在这里执行你的逻辑
            print("检测到删除键被按下")
            
            // 触发外部闭包
            onDeleteBackward?()
            
            // 必须调用 super 以确保原本的删除字符逻辑正常运行
            super.deleteBackward()
        }
    
    // 类似于 shouldChangeTextIn 的底层实现
        override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
            // 在这里编写你的逻辑
            if text == "\n" {
                print("用户按了回车")
                return false // 不允许换行
            }
            
            return super.shouldChangeText(in: range, replacementText: text)
        }
}
