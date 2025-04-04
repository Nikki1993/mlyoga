//
//  ContentView.swift
//  mlyoga
//
//  Created by Nick Kononov on 17.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = FrameHandler()

    var body: some View {
        FrameView(image: model.frame, parts: model.parts).ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
