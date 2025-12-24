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
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    let location: String?
    let company: String?
    let blog: String?
    let htmlUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case bio
        case avatarUrl = "avatar_url"
        case followers
        case following
        case publicRepos = "public_repos"
        case location
        case company
        case blog
        case htmlUrl = "html_url"
    }
}
