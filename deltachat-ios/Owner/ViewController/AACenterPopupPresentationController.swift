//
//  AACenterPopupPresentationController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/24.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import SnapKit

class AACenterPopupPresentationController: UIPresentationController {
    
    // 黑色半透明蒙层
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 动画显示背景
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    // 设置弹出内容的 Frame
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView, let presentedView = presentedView else { return .zero }
        
        // 获取自适应高度
        let targetSize = CGSize(width: containerView.bounds.width - 80, height: UIView.layoutFittingCompressedSize.height)
        let size = presentedView.systemLayoutSizeFitting(targetSize,
                                                         withHorizontalFittingPriority: .required,
                                                         verticalFittingPriority: .fittingSizeLevel)
        
        let x = (containerView.bounds.width - size.width) / 2
        let y = (containerView.bounds.height - size.height) / 2
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
