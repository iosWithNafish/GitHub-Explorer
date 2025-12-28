//
//  GitHubViewModel.swift
//  Sample
//
//  Created by Nafish on 23/12/25.
//

import Foundation
import Combine

// MARK: - ViewState Enums
enum UserSearchState {
    case idle
    case loading
    case loaded(GitHubUser)
    case error(String)
}

enum RepositorySearchState {
    case idle
    case loading
    case loaded([GitHubRepository])
    case error(String)
}

enum FollowersState {
    case idle
    case loading
    case loaded([GitHubUser])
    case error(String)
}

enum FollowingState {
    case idle
    case loading
    case loaded([GitHubUser])
    case error(String)
}

final class GitHubViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var currentUser: GitHubUser?
    @Published var savedUsers: [GitHubUser] = []
    @Published var userSearchState: UserSearchState = .idle
    
    // Repository search properties
    @Published var repositorySearchQuery: String = ""
    @Published var searchedRepositories: [GitHubRepository] = []
    @Published var userRepositories: [GitHubRepository] = []
    @Published var selectedRepository: GitHubRepository?
    @Published var repositorySearchState: RepositorySearchState = .idle
    @Published var savedRepositories: [GitHubRepository] = []
    
    // Followers/Following properties
    @Published var followers: [GitHubUser] = []
    @Published var following: [GitHubUser] = []
    @Published var followersState: FollowersState = .idle
    @Published var followingState: FollowingState = .idle
    
    // Computed properties for backward compatibility
    var isLoading: Bool {
        if case .loading = userSearchState { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = userSearchState {
            return message
        }
        return nil
    }
    
    var isSearchingRepositories: Bool {
        if case .loading = repositorySearchState { return true }
        return false
    }
    
    var repositoryErrorMessage: String? {
        if case .error(let message) = repositorySearchState {
            return message
        }
        return nil
    }
    
    var isLoadingFollowers: Bool {
        if case .loading = followersState { return true }
        return false
    }
    
    var followersErrorMessage: String? {
        if case .error(let message) = followersState {
            return message
        }
        return nil
    }
    
    var isLoadingFollowing: Bool {
        if case .loading = followingState { return true }
        return false
    }
    
    var followingErrorMessage: String? {
        if case .error(let message) = followingState {
            return message
        }
        return nil
    }
    
    func fetchUser() async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            userSearchState = .error("Please enter a GitHub username.")
            currentUser = nil
            return
        }
        
        userSearchState = .loading
        currentUser = nil
        
        let urlString = "https://api.github.com/users/\(trimmed)"
        guard let url = URL(string: urlString) else {
            userSearchState = .error("Invalid username.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                userSearchState = .error("User not found.")
                return
            }
            
            let decoder = JSONDecoder()
            let user = try decoder.decode(GitHubUser.self, from: data)
            currentUser = user
            userSearchState = .loaded(user)
        } catch {
            userSearchState = .error("Failed to load user. Please try again.")
        }
    }
    
    func saveCurrentUser() {
        guard let user = currentUser else { return }
        if !savedUsers.contains(user) {
            savedUsers.append(user)
        }
    }
    
    // MARK: - Repository Search Methods
    
    func searchRepositories() async {
        let trimmed = repositorySearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            repositorySearchState = .error("Please enter a search query.")
            searchedRepositories = []
            return
        }
        
        repositorySearchState = .loading
        searchedRepositories = []
        
        // URL encode the query
        guard let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc&per_page=20") else {
            repositorySearchState = .error("Invalid search query.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 403 {
                    repositorySearchState = .error("Rate limit exceeded. Please try again later.")
                    return
                } else if httpResponse.statusCode != 200 {
                    repositorySearchState = .error("Failed to search repositories.")
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(RepositorySearchResponse.self, from: data)
            searchedRepositories = searchResponse.items
            repositorySearchState = .loaded(searchResponse.items)
        } catch {
            repositorySearchState = .error("Failed to search repositories. Please try again.")
        }
    }
    
    func fetchUserRepositories(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            userRepositories = []
            return
        }
        
        userRepositories = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/repos?sort=updated&per_page=20") else {
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    return
                } else if httpResponse.statusCode == 403 {
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let repositories = try decoder.decode([GitHubRepository].self, from: data)
            userRepositories = repositories
        } catch {
            // Silently fail for user repos as it's a chained call
        }
    }
    
    func saveRepository(_ repository: GitHubRepository) {
        if !savedRepositories.contains(repository) {
            savedRepositories.append(repository)
        }
    }
    
    func removeSavedRepository(_ repository: GitHubRepository) {
        savedRepositories.removeAll { $0.id == repository.id }
    }
    
    // MARK: - Followers/Following Methods
    
    func fetchFollowers(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            followersState = .error("Invalid username.")
            followers = []
            return
        }
        
        followersState = .loading
        followers = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/followers?per_page=100") else {
            followersState = .error("Invalid username.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    followersState = .error("User not found.")
                    return
                } else if httpResponse.statusCode == 403 {
                    followersState = .error("Rate limit exceeded. Please try again later.")
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let followersList = try decoder.decode([GitHubUser].self, from: data)
            followers = followersList
            followersState = .loaded(followersList)
        } catch {
            followersState = .error("Failed to load followers. Please try again.")
        }
    }
    
    func fetchFollowing(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            followingState = .error("Invalid username.")
            following = []
            return
        }
        
        followingState = .loading
        following = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/following?per_page=100") else {
            followingState = .error("Invalid username.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    followingState = .error("User not found.")
                    return
                } else if httpResponse.statusCode == 403 {
                    followingState = .error("Rate limit exceeded. Please try again later.")
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let followingList = try decoder.decode([GitHubUser].self, from: data)
            following = followingList
            followingState = .loaded(followingList)
        } catch {
            followingState = .error("Failed to load following. Please try again.")
        }
    }
    
    func loadUserProfile(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        userSearchState = .loading
        
        let urlString = "https://api.github.com/users/\(trimmed)"
        guard let url = URL(string: urlString) else {
            userSearchState = .error("Invalid username.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                userSearchState = .error("User not found.")
                return
            }
            
            let decoder = JSONDecoder()
            let user = try decoder.decode(GitHubUser.self, from: data)
            currentUser = user
            userSearchState = .loaded(user)
            
            // Chain API calls: fetch repositories, followers, and following
            async let reposTask = fetchUserRepositories(username: user.login)
            async let followersTask = fetchFollowers(username: user.login)
            async let followingTask = fetchFollowing(username: user.login)
            
            _ = await (reposTask, followersTask, followingTask)
        } catch {
            userSearchState = .error("Failed to load user. Please try again.")
        }
    }
}


