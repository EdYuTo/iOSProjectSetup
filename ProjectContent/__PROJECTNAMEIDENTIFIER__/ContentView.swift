//
//  ContentView.swift
//  __PROJECTNAMEIDENTIFIER__
//
//  Created on __DATEIDENTIFIER__.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .accessibilityIdentifier("home.globe")
            Text("Hello, world!")
                .accessibilityIdentifier("home.greeting")
        }
        .padding()
        // Every element agents and UI tests touch gets an identifier: <screen>.<element>[.<qualifier>].
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.root")
    }
}

#Preview {
    ContentView()
}
