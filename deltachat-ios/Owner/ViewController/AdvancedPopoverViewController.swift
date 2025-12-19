//
//  AdvancedPopoverViewController.swift
//  TestMenu
//
//  Created by Gongyonghui on 2025/12/1.
//

import UIKit

struct PopoverOptionsModel {
    var title:String
    var image:String
}

typealias AdvancedPopoverCallback = (Int)->()
class AdvancedPopoverViewController: UIViewController {
    
    private let titleText: String
    private let options: [PopoverOptionsModel]
    
    var callback:AdvancedPopoverCallback?
    
    init(title: String, options: [PopoverOptionsModel]) {
        self.titleText = title
        self.options = options
        super.init(nibName: nil, bundle: nil)
        
        // 必须设置 preferredContentSize
        preferredContentSize = CGSize(width: 150, height: calculateHeight())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCustomAppearance()
    }
    
    private func calculateHeight() -> CGFloat {
        let headerHeight: CGFloat = 5
        let rowHeight: CGFloat = 44
        return headerHeight + (CGFloat(options.count) * rowHeight)
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // 创建容器视图
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOpacity = 0.2
        containerView.translatesAutoresizingMaskIntoConstraints = false
        


        
        // 选项列表
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.alignment = .leading
        stackView.distribution = .fill
        
        for (index, option) in options.enumerated() {
            let optionButton = createOptionButton(title: option.title, tag: index,image: option.image)
            stackView.addArrangedSubview(optionButton)
            optionButton.translatesAutoresizingMaskIntoConstraints = false

            optionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            if index < options.count - 1 {
                let lineSeparator = UIView()
                lineSeparator.backgroundColor = UIColor.init(hexString: "#FFA100")
                lineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(lineSeparator)
            }
        }
        containerView.backgroundColor = .systemOrange
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
    
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 15),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            stackView.heightAnchor.constraint(equalToConstant: 44*4) // 4个按钮 * 60高度 + 3个间距 * 16 = 280

            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: 0)
        ])
    }
    
    private func createOptionButton(title: String, tag: Int,image:String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.tintColor = .white
        button.setImage(UIImage(named: image)?.withTintColor(.white), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.tag = tag
        button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
        

        
        return button
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        print("选择了: \(options[sender.tag])")
        dismiss(animated: true)

        if let callback = callback {
            callback(sender.tag)
        }
    }

    
    private func setupCustomAppearance() {
        guard let popover = popoverPresentationController else { return }
        
        // 自定义背景（影响箭头颜色）
        popover.backgroundColor = UIColor.systemBackground
        
        // 设置弹窗边距
        popover.popoverLayoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}


private func customizeAdvancedPopover(popover: UIPopoverPresentationController) {
    // 设置弹窗与屏幕边缘的最小间距
    popover.popoverLayoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    // 背景色会影响箭头颜色
    if #available(iOS 13.0, *) {
        popover.backgroundColor = .systemBackground
    }
}

