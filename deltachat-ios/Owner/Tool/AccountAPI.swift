//
//  AccountAPI.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/7.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import Foundation
import DcCore
import OSLog


// MARK: - Request Body Structure
struct CreateAccountRequest: Encodable {
    let domain: String
    let address: String
    let password: String
}

// MARK: - Response Body Structure
struct CreateAccountResponse: Decodable {
    let account: String
    let success: Bool
    let error:String

}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

// MARK: - Account API
class AccountAPI {

    static func createAccount(parm:CreateAccountRequest,completion: @escaping (Result<CreateAccountResponse, APIError>) -> Void) {
        logger.info("Attempting to create account...")
        guard let url = URL(string: "http://aa.aa1234.com/create-account") else {
                        logger.error("Invalid URL for create-account endpoint.")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

//        let requestBody = CreateAccountRequest(
//            domain: "aa1234.com",
//            address: "atessfdsat12@aa1234.com",
//            password: "123456"
//        )
//let parm
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(parm)
        } catch {
                        logger.error("Failed to encode request body: \(error.localizedDescription)")
            completion(.failure(.decodingError(error)))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                                logger.error("API request failed: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                                logger.warning("Invalid response from server.")
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let createAccountResponse = try decoder.decode(CreateAccountResponse.self, from: data)
                                logger.info("Successfully created account: \(createAccountResponse.account)")
                completion(.success(createAccountResponse))
            } catch {
                                logger.error("Failed to decode response: \(error.localizedDescription)")
                completion(.failure(.decodingError(error)))
            }
        }

        task.resume()
    }
}

// MARK: - Example Usage
/*
AccountAPI.createAccount { result in
    switch result {
    case .success(let response):
        print("Account created: \(response.account), Success: \(response.success)")
    case .failure(let error):
        print("Error creating account: \(error.localizedDescription)")
    }
}
*/
