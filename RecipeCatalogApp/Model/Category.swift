//
//  Category.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/21/24.
//

import Foundation
import SwiftData

@Model
final class Category: Identifiable {
    var name: String
    @Relationship
    var recipes: [Recipe]
    
    var id: UUID = UUID()

    init(name: String) {
        self.name = name
        self.recipes = []
    }
}



