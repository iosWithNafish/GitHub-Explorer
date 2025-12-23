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
}


