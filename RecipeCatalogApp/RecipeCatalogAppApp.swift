//
//  RecipeCatalogAppApp.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/18/24.
//

import SwiftUI
import SwiftData

@main
struct RecipeCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            DefaultMainView()
        }
        .modelContainer(for: [Recipe.self])
    }
}
