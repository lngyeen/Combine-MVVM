//
//  UITextField.Publisher.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation
import UIKit

extension UITextField {
    var publisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField? }
            .map { $0?.text }
            .eraseToAnyPublisher()
    }
}
