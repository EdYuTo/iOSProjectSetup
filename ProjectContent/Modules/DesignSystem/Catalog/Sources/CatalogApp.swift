//
//  CatalogApp.swift
//  DesignSystemCatalog
//
//  Created on __DATEIDENTIFIER__.
//

import SwiftUI

@main
struct CatalogApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogList(entries: CatalogEntry.all)
        }
    }
}
