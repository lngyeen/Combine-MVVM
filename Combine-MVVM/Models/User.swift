//
//  User.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Foundation

final class User {
    var username: String
    var password: String
    var isLogin = false
    var about = "n/a"

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
