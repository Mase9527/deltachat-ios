//
//  AABaseNavigationController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/16.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

class AABaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }

    // 统一处理侧滑手势
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
