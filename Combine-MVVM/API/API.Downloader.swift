//
//  API.Downloader.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation
import UIKit

extension API.Downloader {
    static func image(urlString: String) -> AnyPublisher<UIImage?, API.APIError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: API.APIError.errorURL).eraseToAnyPublisher()
        }

        return API.request(url: url)
            .map { UIImage(data: $0) }
            .mapError { $0 as? API.APIError ?? .unknown }
            .eraseToAnyPublisher()
    }
}
