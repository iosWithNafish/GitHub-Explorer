//
//  ContentView.swift
//  Sample
//
//  Created by Nafish on 22/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
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
                        // Main glass card
                        VStack(spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 6) {
                                Text("GitHub Explorer")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Search any GitHub username and save your favourites.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Search input
                            HStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                                    
                                    TextField("Enter GitHub username", text: $viewModel.username)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                }
                                .padding(14)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.8)
                                )
                                
                                Button {
                                    Task {
                                        await viewModel.fetchUser()
                                    }
                                } label: {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 26, weight: .semibold))
                                    }
                                }
                                .padding(10)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 10)
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
                                userDetailCard(user: user) {
                                    viewModel.saveCurrentUser()
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
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.9)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 25, x: 0, y: 20)
                        
                        // Saved users list as a separate glass card
                        if !viewModel.savedUsers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Saved Users")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(viewModel.savedUsers.count)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                
                                VStack(spacing: 10) {
                                    ForEach(viewModel.savedUsers) { user in
                                        HStack(spacing: 12) {
                                            avatarView(urlString: user.avatarUrl, size: 40)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(user.name ?? user.login)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                Text("@\(user.login)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.6)
                                        )
                                    }
                                }
                            }
                            .padding(18)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.8)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 18, x: 0, y: 12)
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
    
    @ViewBuilder
    private func userDetailCard(user: GitHubUser, onSave: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                avatarView(urlString: user.avatarUrl, size: 80)
                
                VStack(alignment: .leading, spacing: 4) {
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
            }
            
            HStack {
                Button {
                    onSave()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bookmark.fill")
                        Text("Save User")
                    }
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.9)
        )
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
    ContentView()
}
