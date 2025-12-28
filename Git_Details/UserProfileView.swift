//
//  UserProfileView.swift
//  Git_Details
//
//  Created by Nafish on 23/12/25.
//

import SwiftUI

struct UserProfileView: View {
    let username: String
    @StateObject private var viewModel = GitHubViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                        if let user = viewModel.currentUser {
                            // User profile card
                            userProfileCard(user: user)
                            
                            // Stats and actions
                            statsAndActionsCard(user: user)
                            
                            // Repositories section
                            if !viewModel.userRepositories.isEmpty {
                                repositoriesSectionCard
                            }
                            
                            // Followers section
                            followersSectionCard
                            
                            // Following section
                            followingSectionCard
                        } else if viewModel.isLoading {
                            ProgressView()
                                .padding(.vertical, 40)
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadUserProfile(username: username)
        }
    }
    
    // MARK: - User Profile Card
    @ViewBuilder
    private func userProfileCard(user: GitHubUser) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                avatarView(urlString: user.avatarUrl, size: 100)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name ?? user.login)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let location = user.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(location)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let htmlUrl = user.htmlUrl, let url = URL(string: htmlUrl) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "link")
                        Text("View on GitHub")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Stats and Actions Card
    @ViewBuilder
    private func statsAndActionsCard(user: GitHubUser) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                statItem(value: "\(user.followers ?? 0)", label: "Followers", icon: "person.2.fill", color: .blue)
                statItem(value: "\(user.following ?? 0)", label: "Following", icon: "person.fill", color: .purple)
                statItem(value: "\(user.publicRepos ?? 0)", label: "Repos", icon: "book.fill", color: .green)
            }
            
            Button {
                viewModel.saveCurrentUser()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.savedUsers.contains(user) ? "bookmark.fill" : "bookmark")
                    Text(viewModel.savedUsers.contains(user) ? "Saved" : "Save User")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Repositories Section
    private var repositoriesSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Repositories")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.userRepositories.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(Capsule())
            }
            
            VStack(spacing: 10) {
                ForEach(Array(viewModel.userRepositories.prefix(10)), id: \.id) { repo in
                    repositoryRowCard(repository: repo)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Followers Section
    private var followersSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Followers")
                    .font(.headline)
                Spacer()
                if viewModel.isLoadingFollowers {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("\(viewModel.followers.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            if let error = viewModel.followersErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if viewModel.followers.isEmpty && !viewModel.isLoadingFollowers {
                Text("No followers")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(viewModel.followers.prefix(20)), id: \.id) { follower in
                        NavigationLink(destination: UserProfileView(username: follower.login)) {
                            followerRowCard(user: follower)
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
    
    // MARK: - Following Section
    private var followingSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Following")
                    .font(.headline)
                Spacer()
                if viewModel.isLoadingFollowing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("\(viewModel.following.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            if let error = viewModel.followingErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if viewModel.following.isEmpty && !viewModel.isLoadingFollowing {
                Text("Not following anyone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(viewModel.following.prefix(20)), id: \.id) { user in
                        NavigationLink(destination: UserProfileView(username: user.login)) {
                            followerRowCard(user: user)
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
    
    // MARK: - Reusable Components
    @ViewBuilder
    private func followerRowCard(user: GitHubUser) -> some View {
        VStack(spacing: 8) {
            avatarView(urlString: user.avatarUrl, size: 60)
            
            VStack(spacing: 2) {
                Text(user.name ?? user.login)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("@\(user.login)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("\(repository.stars)")
                        .font(.caption2)
                }
                
                if let language = repository.language {
                    Text(language)
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
}

#Preview {
    UserProfileView(username: "apple")
}

