//
//  Recipe.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/18/24.
//

import Foundation
import SwiftData

@Model
// Final means you can't inherit
// Can't be a struct. Model only applies to a class
// Classes we pass the reference not a copy
final class Recipe {
    var title: String
    var ingredients: String
    var instructions: String
    
    init(title: String, ingredients: String, instructions: String) {
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
    }
}
