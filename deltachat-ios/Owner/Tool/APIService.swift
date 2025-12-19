//
//  APIService.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/7.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import Foundation

// 定义请求和响应模型
struct Post: Codable {
    let title: String
    let body: String
    let userId: Int
}

struct PostResponse: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

class APIService {
    
    static let shared = APIService()
    private let session = URLSession.shared
    
    func createPost(_ post: Post, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(post)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            // 处理网络错误
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 检查 HTTP 状态码
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // 解析响应数据
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let postResponse = try decoder.decode(PostResponse.self, from: data)
                completion(.success(postResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

extension APIService {
    
    enum ContentType {
        case json
        case formURLEncoded
        case multipartFormData(boundary: String)
        
        var headerValue: String {
            switch self {
            case .json:
                return "application/json"
            case .formURLEncoded:
                return "application/x-www-form-urlencoded"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            }
        }
    }
    
    func sendPostRequest<T: Decodable>(
        to urlString: String,
        parameters: [String: Any]? = nil,
        contentType: ContentType = .json,
        completion: @escaping (Result<T, Error>) -> Void
    )
    {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
        
        // 设置请求体
        if let parameters = parameters {
            switch contentType {
            case .json:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    
//                    let encoder = JSONEncoder()
//                    request.httpBody = try encoder.encode(parameters)
                    
                } catch {
                    completion(.failure(error))
                    return
                }
                
            case .formURLEncoded:
                let formString = parameters.map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                request.httpBody = formString?.data(using: .utf8)
                
            case .multipartFormData(let boundary):
                request.httpBody = createMultipartFormData(parameters: parameters, boundary: boundary)
            }
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("状态码: \(httpResponse.statusCode)")
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func createMultipartFormData(parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: .utf8)!)
            
            if let dataValue = value as? Data {
                // 处理文件数据
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"file.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(dataValue)
                body.append("\r\n".data(using: .utf8)!)
            } else {
                // 处理文本数据
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}


@available(iOS 15.0, *)
extension APIService {
    
    func createPostAsync(_ post: Post) async throws -> PostResponse {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(post)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(PostResponse.self, from: data)
    }
}

// 使用 async/await 示例
@available(iOS 15.0, *)
func testAsyncPost() async {
    let post = Post(title: "Async POST", body: "使用 async/await 的 POST 请求", userId: 1)
    
    do {
        let response = try await APIService.shared.createPostAsync(post)
        print("异步请求成功: \(response)")
    } catch {
        print("异步请求失败: \(error)")
    }
}
