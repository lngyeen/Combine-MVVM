//
//  API.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation

struct API {
    // MARK: - Error

    enum APIError: Error {
        case error(String)
        case errorURL
        case invalidResponse
        case errorParsing
        case unknown
    
        var localizedDescription: String {
            switch self {
            case .error(let string):
                return string
            case .errorURL:
                return "URL String is error."
            case .invalidResponse:
                return "Invalid response"
            case .errorParsing:
                return "Failed parsing response from server"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
  
    // MARK: - Config

    enum Config {
        static let baseURL = "https://rss.applemarketingtools.com/"
    }
  
    // MARK: - Logic API

    struct Downloader {}
  
    // MARK: - Business API

    struct Music {}
}
