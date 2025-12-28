//
//  ContentView.swift
//  Sample
//
//  Created by Nafish on 22/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GitHubViewModel()
    @State private var selectedTab: SearchTab = .users
    
    enum SearchTab {
        case users
        case repositories
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.5),
                        Color.purple.opacity(0.4),
                        Color.cyan.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .blur(radius: 30)
                
                ScrollView {
                        VStack(spacing: 24) {
                            // Header
                        VStack(alignment: .leading, spacing: 8) {
                                Text("GitHub Explorer")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                            Text("Search users and repositories, save your favourites.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                            
                        // Tab selector
                        Picker("Search Type", selection: $selectedTab) {
                            Text("Users").tag(SearchTab.users)
                            Text("Repositories").tag(SearchTab.repositories)
                        }
                        .pickerStyle(.segmented)
                        
                        // Content based on selected tab
                        if selectedTab == .users {
                            userSearchSection
                        } else {
                            repositorySearchSection
                        }
                        
                        // Saved users list
                        if !viewModel.savedUsers.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Saved Users")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(viewModel.savedUsers.count)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                        ForEach(viewModel.savedUsers, id: \.id) { user in
                                            NavigationLink(destination: UserProfileView(username: user.login)) {
                                                VStack(spacing: 8) {
                                                    avatarView(urlString: user.avatarUrl, size: 60)
                                                    Text(user.name ?? user.login)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .lineLimit(1)
                                                        .frame(width: 70)
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 16)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Capsule())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        // Saved repositories list
                        if !viewModel.savedRepositories.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Saved Repositories")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(viewModel.savedRepositories.count)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(viewModel.savedRepositories, id: \.id) { repo in
                                        repositoryRowCard(repository: repo)
                                    }
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - User Search Section
    private var userSearchSection: some View {
        VStack(spacing: 24) {
            // Search input
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                        .font(.system(size: 16))
                                    
                                    TextField("Enter GitHub username", text: $viewModel.username)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                                
                                AsyncButton {
                                    await viewModel.loadUserProfile(username: viewModel.username)
                                } label: {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .frame(width: 24, height: 24)
                                    } else {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                .frame(width: 48, height: 48)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                .clipShape(Circle())
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Error message
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Current user details
                            if let user = viewModel.currentUser {
                NavigationLink(destination: UserProfileView(username: user.login)) {
                                userDetailCard(user: user) {
                                    viewModel.saveCurrentUser()
                    }
                }
                .buttonStyle(.plain)
                
                // User repositories
                if !viewModel.userRepositories.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Repositories")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(viewModel.userRepositories.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.userRepositories.prefix(5)), id: \.id) { repo in
                                repositoryRowCard(repository: repo)
                            }
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                }
                            } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                                // Placeholder when nothing is loaded yet
                                VStack(spacing: 10) {
                                    Image(systemName: "person.crop.circle.badge.questionmark")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.secondary)
                                    Text("Start by searching for a GitHub user.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                        }
    }
    
    // MARK: - Repository Search Section
    private var repositorySearchSection: some View {
        VStack(spacing: 24) {
            // Search input
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search repositories (e.g., swift, react)", text: $viewModel.repositorySearchQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                        .background(.ultraThinMaterial)
                .clipShape(Capsule())
                
                AsyncButton {
                    await viewModel.searchRepositories()
                } label: {
                    if viewModel.isSearchingRepositories {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                        )
                .clipShape(Circle())
                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Error message
            if let error = viewModel.repositoryErrorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Search results
            if !viewModel.searchedRepositories.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                                HStack {
                        Text("Search Results")
                                        .font(.headline)
                            .fontWeight(.semibold)
                                    Spacer()
                        Text("\(viewModel.searchedRepositories.count)")
                                        .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.purple.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                
                    VStack(spacing: 12) {
                        ForEach(viewModel.searchedRepositories, id: \.id) { repo in
                            repositoryDetailCard(repository: repo)
                                            }
                    }
                                        }
                .padding(20)
                                        .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            } else if !viewModel.isSearchingRepositories && viewModel.repositoryErrorMessage == nil {
                // Placeholder when nothing is loaded yet
                VStack(spacing: 10) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Search for repositories by keyword or technology.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                }
        }
    }
    
    @ViewBuilder
    private func userDetailCard(user: GitHubUser, onSave: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                avatarView(urlString: user.avatarUrl, size: 80)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.name ?? user.login)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Stats row
            HStack(spacing: 16) {
                statButton(value: "\(user.followers ?? 0)", label: "Followers", icon: "person.2.fill", color: .blue)
                statButton(value: "\(user.following ?? 0)", label: "Following", icon: "person.fill", color: .purple)
                statButton(value: "\(user.publicRepos ?? 0)", label: "Repos", icon: "book.fill", color: .green)
            }
            .padding(.vertical, 4)
            
            HStack(spacing: 12) {
                Button {
                    onSave()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.savedUsers.contains(user) ? "bookmark.fill" : "bookmark")
                        Text(viewModel.savedUsers.contains(user) ? "Saved" : "Save")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("View Profile")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundStyle(.blue)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    private func statButton(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func avatarView(urlString: String?, size: CGFloat) -> some View {
        if let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                case .failure(_):
                    placeholderAvatar(size: size)
                @unknown default:
                    placeholderAvatar(size: size)
                }
            }
            .frame(width: size, height: size)
        } else {
            placeholderAvatar(size: size)
        }
    }
    
    private func placeholderAvatar(size: CGFloat) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundStyle(.gray)
            )
            .frame(width: size, height: size)
    }
    
    // MARK: - Repository Views
    @ViewBuilder
    private func repositoryDetailCard(repository: GitHubRepository) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                avatarView(urlString: repository.owner.avatarUrl, size: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(repository.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(repository.owner.login)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    if viewModel.savedRepositories.contains(repository) {
                        viewModel.removeSavedRepository(repository)
                    } else {
                        viewModel.saveRepository(repository)
                    }
                } label: {
                    Image(systemName: viewModel.savedRepositories.contains(repository) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundStyle(viewModel.savedRepositories.contains(repository) ? .yellow : .secondary)
                }
            }
            
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("\(repository.stars)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Capsule())
                
                HStack(spacing: 4) {
                    Image(systemName: "tuningfork")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(repository.forks)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
                
                if let language = repository.language {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                        Text(language)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                Link(destination: URL(string: repository.htmlUrl)!) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private func repositoryRowCard(repository: GitHubRepository) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("\(repository.stars)")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                if let language = repository.language {
                    Text(language)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
}
