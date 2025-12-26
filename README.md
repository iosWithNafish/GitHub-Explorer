# GitHub Explorer – Liquid Glass iOS App

GitHub Explorer is a SwiftUI iOS app that lets you quickly look up any GitHub user by username, see their profile details, and save your favourite profiles — all in a modern “liquid glass” (glassmorphism) UI.

## Features

- **Search GitHub users**
  - Enter any GitHub username and fetch their public profile.
  - See name, username, avatar, and bio.

- **Save favourite users**
  - Save profiles you care about to a local “Saved Users” list.
  - Quickly revisit the people you look up the most.

- **Modern liquid-glass design**
  - Blurred gradient background.
  - Glassmorphism cards using `ultraThinMaterial`.
  - Dark-mode friendly and built with SwiftUI.

## Screenshots

<img width="379" height="818" alt="Simulator Screenshot - iPhone 15 - 2025-12-24 at 18 24 23" src="https://github.com/user-attachments/assets/bd93cf58-6f17-4c1e-828d-9d4a67da3a49" />
<img width="379" height="818" alt="Simulator Screenshot - iPhone 15 - 2025-12-24 at 18 22 40" src="https://github.com/user-attachments/assets/1ceaf68f-6a2e-4401-af13-52583d6be078" />





## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM (simple)
- **Networking**: `URLSession` calling the public GitHub REST API

## Project Structure

- `SampleApp.swift` – App entry point.
- `ContentView.swift` – Main UI (search, profile card, saved users).
- `GitHubUser.swift` – GitHub user model.
- `GitHubViewModel.swift` – ViewModel for handling API calls and state.

Minimum Deployement - 26.0
Sported Destination - iPhone, iPad, Mac

