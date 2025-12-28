//
//  AsyncButton.swift
//  Git_Details
//
//  Created by Nafish on 23/12/25.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    private let action: () async -> Void
    private let label: Label
    @State private var isRunning = false
    
    init(action: @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button {
            isRunning = true
        } label: {
            label
        }
        .disabled(isRunning)
        .task(id: isRunning) {
            guard isRunning else { return }
            await action()
            isRunning = false
        }
    }
}

// Convenience initializer for String labels
extension AsyncButton where Label == Text {
    init(_ title: String, action: @escaping () async -> Void) {
        self.action = action
        self.label = Text(title)
    }
}

