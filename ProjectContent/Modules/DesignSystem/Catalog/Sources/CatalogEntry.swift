//
//  CatalogEntry.swift
//  DesignSystemCatalog
//
//  Created on __DATEIDENTIFIER__.
//

import DesignSystem
import SwiftUI

/// One page of the catalog: a token group or a component with its states.
struct CatalogEntry: Identifiable {
    let id: String
    let title: String
    let page: AnyView

    /// Add an entry for every token group and component you add to DesignSystem.
    static let all: [CatalogEntry] = []
}

struct CatalogList: View {
    let entries: [CatalogEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No components yet",
                        systemImage: "square.grid.2x2",
                        description: Text(
                            "Add tokens and components to \(DesignSystem.name), then list them in CatalogEntry.all."
                        )
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("catalog.empty")
                } else {
                    List(entries) { entry in
                        NavigationLink(entry.title) { entry.page.navigationTitle(entry.title) }
                            .accessibilityIdentifier("catalog.entry.\(entry.id)")
                    }
                    .accessibilityIdentifier("catalog.list")
                }
            }
            .navigationTitle("Catalog")
        }
    }
}
