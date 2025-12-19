import Foundation

class DocumentManager {
    
    // 获取 Document 目录路径
    static func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getDocumentDirectoryString() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if #available(iOS 16.0, *) {
            return paths[0].path()
        } else {
            // Fallback on earlier versions
            return paths[0].path
        }
    }
    
    // 获取 Library 目录路径
    static func getLibraryDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // 获取 Caches 目录路径
    static func getCachesDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getAllFilesInDirectory(at url: URL) -> [URL] {
        var fileURLs: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            for case let fileURL as URL in enumerator {
                let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey])
                if let isDirectory = resourceValues?.isDirectory, !isDirectory {
                    fileURLs.append(fileURL)
                }
            }
        }
        return fileURLs
    }
}

extension DocumentManager {
    
    // 创建文件夹
    static func createDirectory(named directoryName: String) -> Bool {
        let directoryURL = getDocumentDirectory().appendingPathComponent(directoryName)
        
        do {
            try FileManager.default.createDirectory(at: directoryURL,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
            print("文件夹创建成功: \(directoryURL.path)")
            return true
        } catch {
            print("文件夹创建失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // 创建文本文件
    static func createTextFile(named fileName: String, content: String) -> Bool {
        let fileURL = getDocumentDirectory().appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("文本文件创建成功: \(fileURL.path)")
            return true
        } catch {
            print("文本文件创建失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // 创建二进制文件
    static func createBinaryFile(named fileName: String, data: Data) -> Bool {
        let fileURL = getDocumentDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("二进制文件创建成功: \(fileURL.path)")
            return true
        } catch {
            print("二进制文件创建失败: \(error.localizedDescription)")
            return false
        }
    }
}
