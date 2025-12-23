//
//  GitHubUser.swift
//  Sample
//
//  Created by Nafish on 23/12/25.
//

import Foundation

struct GitHubUser: Identifiable, Decodable, Equatable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case bio
        case avatarUrl = "avatar_url"
    }
}
