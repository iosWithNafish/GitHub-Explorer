//
//  GitHubRepository.swift
//  Git_Details
//
//  Created by Nafish on 23/12/25.
//

import Foundation

struct GitHubRepository: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let stars: Int
    let forks: Int
    let watchers: Int
    let openIssues: Int
    let isPrivate: Bool
    let isFork: Bool
    let createdAt: String
    let updatedAt: String
    let pushedAt: String?
    let htmlUrl: String
    let owner: RepositoryOwner
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case language
        case stars = "stargazers_count"
        case forks
        case watchers
        case openIssues = "open_issues_count"
        case isPrivate = "private"
        case isFork = "fork"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case htmlUrl = "html_url"
        case owner
    }
}

struct RepositoryOwner: Decodable, Equatable {
    let login: String
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}

struct RepositorySearchResponse: Decodable {
    let items: [GitHubRepository]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}

