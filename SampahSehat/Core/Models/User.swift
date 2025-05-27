//
//  User.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String { userId }
    var userId: String
    var email: String
    var locationInfo: String
    var role: String

    enum CodingKeys: String, CodingKey {
        case userId
        case email
        case locationInfo
        case role
    }
}
