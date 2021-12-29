//
//  Music.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation
import UIKit

class Music: Codable {
    var name: String
    var id: String
    var artistName: String
    var artworkUrl100: String
    
    var isLiked: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case name
        case id
        case artistName
        case artworkUrl100
    }
}
