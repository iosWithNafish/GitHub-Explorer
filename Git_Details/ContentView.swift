//
//  ContentView.swift
//  Git_Details
//
//  Created by Nafish on 11/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var user:GitHubUser?
    @State private var searchUser = ""
    var body: some View {
            VStack(spacing:20) {
                Text("GitHub User Details")
                    .font(.largeTitle)
                    .padding()
                TextField("Search User Name: ",text:  $searchUser)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                    )
                    .padding(.horizontal)
                
                HStack {
                    Button("Search") {
                        Task {
                            do {
                                user = try await getUser()
                            } catch {
                                print("Error:", error)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(5)
                    
                    Button("Save  ") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                   
                
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) {Image in
                    Image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                .frame(width: 120, height: 120)
                
                Text(user?.login ?? "Login Placeholder")
                    .bold()
                    .font(.title3)
                Text(user?.bio ?? "Bio Placeholder")
                    .padding()
                
                Spacer()
            }
            .padding()
        
        //.searchable(text: $searchUser,placement: .automatic, prompt: "Search User")
     //iosWithNafish
    }
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/\(searchUser)"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data,response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {throw GHError.invalidResponse
        }
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }catch{
            throw GHError.invalidData
        }
    }
    
}

#Preview {
    ContentView()
}
struct GitHubUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String?
}
enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
