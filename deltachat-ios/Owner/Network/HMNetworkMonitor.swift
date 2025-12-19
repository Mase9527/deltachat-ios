//
//  HMNetworkMonitor.swift
//  DUNU
//
//  Created by gongyonghui on 2024/6/13.
//

import UIKit
import Network

class HMNetworkMonitor: NSObject {
    let monitor = NWPathMonitor()
    @Published public var status:NWPath.Status?
    public static let shared = HMNetworkMonitor()
    private override init() {
        super.init()
        monitor.pathUpdateHandler = {[weak self]
            path in
            if path.status == .satisfied {
                
//                let s = QCYDeviceListTool.share
            } else {
                print("网络未连接")
            }
            self?.status = path.status
        }
    }
    public func startMonitor() {
        monitor.start(queue: DispatchQueue.global())
    }
    public func cancelMonitor() {
        monitor.cancel()
    }
}
