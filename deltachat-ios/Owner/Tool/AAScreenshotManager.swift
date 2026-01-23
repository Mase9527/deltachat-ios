import UIKit
import Photos

class AAScreenshotManager: NSObject {
    static let shared = AAScreenshotManager()
    
    var lastScreenshot: UIImage?
    private var timer: Timer?
    private var lastObservedAssetIdentifier: String? // 记录最后一次处理的图片 ID，防止重复

    func startListening() {
        // 1. 监听应用内截图通知
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
        // 2. 监听相册变化（核心：处理应用外截图）
        PHPhotoLibrary.shared().register(self)
    }

    @objc private func didTakeScreenshot() {
        handleNewPhoto()
    }

    private func handleNewPhoto() {
        // 延迟获取，确保系统已写入相册
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchLastPhoto { [weak self] image, assetID in
                // 如果这张图还没被处理过
                if let assetID = assetID, assetID != self?.lastObservedAssetIdentifier {
                    self?.lastObservedAssetIdentifier = assetID
                    self?.lastScreenshot = image
//                    self?.startCleanupTimer()
                    print("检测到新截图（应用内或相册新增）")
                }
            }
        }
    }

    private func fetchLastPhoto(completion: @escaping (UIImage?, String?) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        
        let result = PHAsset.fetchAssets(with: .image, options: options)
        guard let asset = result.firstObject else { return }
        
        // 校验是否是最近 10 秒内生成的图，防止误触旧图
        if abs(asset.creationDate?.timeIntervalSinceNow ?? -100) > 10 { return }

        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 500), contentMode: .aspectFill, options: requestOptions) { image, _ in
            completion(image, asset.localIdentifier)
        }
    }

    private func startCleanupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.clearCache()
        }
    }

    func clearCache() {
        self.lastScreenshot = nil
        self.timer?.invalidate()
        self.timer = nil
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension AAScreenshotManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 当相册发生变化时（如应用外截图后回到 App），触发检测
        DispatchQueue.main.async {
            self.handleNewPhoto()
        }
    }
}
