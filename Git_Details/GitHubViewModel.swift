//
//  GitHubViewModel.swift
//  Sample
//
//  Created by Nafish on 23/12/25.
//

import Foundation
import Combine

final class GitHubViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var currentUser: GitHubUser?
    @Published var savedUsers: [GitHubUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Repository search properties
    @Published var repositorySearchQuery: String = ""
    @Published var searchedRepositories: [GitHubRepository] = []
    @Published var userRepositories: [GitHubRepository] = []
    @Published var selectedRepository: GitHubRepository?
    @Published var isSearchingRepositories: Bool = false
    @Published var repositoryErrorMessage: String?
    @Published var savedRepositories: [GitHubRepository] = []
    
    // Followers/Following properties
    @Published var followers: [GitHubUser] = []
    @Published var following: [GitHubUser] = []
    @Published var isLoadingFollowers: Bool = false
    @Published var isLoadingFollowing: Bool = false
    @Published var followersErrorMessage: String?
    @Published var followingErrorMessage: String?
    
    func fetchUser() async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a GitHub username."
            currentUser = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        currentUser = nil
        
        let urlString = "https://api.github.com/users/\(trimmed)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid username."
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                errorMessage = "User not found."
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let user = try decoder.decode(GitHubUser.self, from: data)
            currentUser = user
        } catch {
            errorMessage = "Failed to load user. Please try again."
        }
        
        isLoading = false
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
            repositoryErrorMessage = "Please enter a search query."
            searchedRepositories = []
            return
        }
        
        isSearchingRepositories = true
        repositoryErrorMessage = nil
        searchedRepositories = []
        
        // URL encode the query
        guard let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc&per_page=20") else {
            repositoryErrorMessage = "Invalid search query."
            isSearchingRepositories = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 403 {
                    repositoryErrorMessage = "Rate limit exceeded. Please try again later."
                    isSearchingRepositories = false
                    return
                } else if httpResponse.statusCode != 200 {
                    repositoryErrorMessage = "Failed to search repositories."
                    isSearchingRepositories = false
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(RepositorySearchResponse.self, from: data)
            searchedRepositories = searchResponse.items
        } catch {
            repositoryErrorMessage = "Failed to search repositories. Please try again."
        }
        
        isSearchingRepositories = false
    }
    
    func fetchUserRepositories(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            repositoryErrorMessage = "Please enter a GitHub username."
            userRepositories = []
            return
        }
        
        isSearchingRepositories = true
        repositoryErrorMessage = nil
        userRepositories = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/repos?sort=updated&per_page=20") else {
            repositoryErrorMessage = "Invalid username."
            isSearchingRepositories = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    repositoryErrorMessage = "User not found."
                    isSearchingRepositories = false
                    return
                } else if httpResponse.statusCode == 403 {
                    repositoryErrorMessage = "Rate limit exceeded. Please try again later."
                    isSearchingRepositories = false
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let repositories = try decoder.decode([GitHubRepository].self, from: data)
            userRepositories = repositories
        } catch {
            repositoryErrorMessage = "Failed to load repositories. Please try again."
        }
        
        isSearchingRepositories = false
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
            followersErrorMessage = "Invalid username."
            followers = []
            return
        }
        
        isLoadingFollowers = true
        followersErrorMessage = nil
        followers = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/followers?per_page=100") else {
            followersErrorMessage = "Invalid username."
            isLoadingFollowers = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    followersErrorMessage = "User not found."
                    isLoadingFollowers = false
                    return
                } else if httpResponse.statusCode == 403 {
                    followersErrorMessage = "Rate limit exceeded. Please try again later."
                    isLoadingFollowers = false
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let followersList = try decoder.decode([GitHubUser].self, from: data)
            followers = followersList
        } catch {
            followersErrorMessage = "Failed to load followers. Please try again."
        }
        
        isLoadingFollowers = false
    }
    
    func fetchFollowing(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            followingErrorMessage = "Invalid username."
            following = []
            return
        }
        
        isLoadingFollowing = true
        followingErrorMessage = nil
        following = []
        
        guard let url = URL(string: "https://api.github.com/users/\(trimmed)/following?per_page=100") else {
            followingErrorMessage = "Invalid username."
            isLoadingFollowing = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    followingErrorMessage = "User not found."
                    isLoadingFollowing = false
                    return
                } else if httpResponse.statusCode == 403 {
                    followingErrorMessage = "Rate limit exceeded. Please try again later."
                    isLoadingFollowing = false
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let followingList = try decoder.decode([GitHubUser].self, from: data)
            following = followingList
        } catch {
            followingErrorMessage = "Failed to load following. Please try again."
        }
        
        isLoadingFollowing = false
    }
    
    func loadUserProfile(username: String) async {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://api.github.com/users/\(trimmed)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid username."
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                errorMessage = "User not found."
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let user = try decoder.decode(GitHubUser.self, from: data)
            currentUser = user
            
            // Chain API calls: fetch repositories, followers, and following
            async let reposTask = fetchUserRepositories(username: user.login)
            async let followersTask = fetchFollowers(username: user.login)
            async let followingTask = fetchFollowing(username: user.login)
            
            _ = await (reposTask, followersTask, followingTask)
        } catch {
            errorMessage = "Failed to load user. Please try again."
        }
        
        isLoading = false
    }
}


