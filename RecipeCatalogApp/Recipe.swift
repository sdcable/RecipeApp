//
//  Recipe.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/18/24.
//

import Foundation
import SwiftData

@Model
final class Recipe{
    var title: String
    var ingredients: String
    var instructions: String
    var searchString: String

    var date: Date
    var time_required: String
    var servings: Int
    var difficulty: String
    var calories_per_serving: Double
    var favorite_bool: Bool
    var general_notes: String

    @Relationship
    var categories: [Category]

    init(title: String,
         ingredients: String,
         instructions: String,
         searchString: String,
         date: Date,
         time_required: String,
         servings: Int,
         difficulty: String,
         calories_per_serving: Double,
         favorite_bool: Bool,
         general_notes: String) {
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.searchString = searchString
        self.date = date
        self.time_required = time_required
        self.servings = servings
        self.difficulty = difficulty
        self.calories_per_serving = calories_per_serving
        self.favorite_bool = favorite_bool
        self.general_notes = general_notes
        self.categories = []
    }
}

