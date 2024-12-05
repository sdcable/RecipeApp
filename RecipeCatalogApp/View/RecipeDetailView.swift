//
//  RecipeDetailView.swift
//  RecipeCatalogApp
//
//  Created by IS 543 on 11/27/24.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    var recipe: Recipe

    @State private var isPresentingEditView: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Date
                headerSection
                
                // Other Details
                otherDetailsSection

                // Ingredients Section
                ingredientsSection

                // Instructions Section
                instructionsSection

                
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    isPresentingEditView = true
                }
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingEditView) {
            AddRecipeView(isPresented: $isPresentingEditView, recipeToEdit: recipe)
        }
    }

    // Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Recipe Title
                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Categories
                if !recipe.categories.isEmpty {
                    HStack {
                        ForEach(recipe.categories, id: \.id) { category in
                            Text(category.name)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            Spacer()

            // Date
            Text(recipe.date, format: .dateTime.year().month().day())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
            let ingredientsList = recipe.ingredients.split(separator: ",")
            ForEach(ingredientsList, id: \.self) { ingredient in
                Text("• \(ingredient)")
                    .font(.body)
            }
        }
        .padding(.vertical, 10)
    }

    // Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)
            let instructionsList = recipe.instructions.split(separator: ",")
            ForEach(Array(instructionsList.enumerated()), id: \.offset) { index, step in
                Text("\(index + 1). \(step)")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 10)
    }

    // Other Details Section
    private var otherDetailsSection: some View {
        Group {
            DetailRow(label: "Servings", content: "\(recipe.servings)")
            DetailRow(label: "Difficulty", content: recipe.difficulty)
            DetailRow(label: "Calories Per Serving", content: "\(recipe.calories_per_serving)")
            DetailRow(label: "Notes", content: recipe.general_notes)
        }
    }
}



// Helper for displaying rows
struct DetailRow: View {
    let label: String
    let content: String?
    let dateContent: Date?
    var format: Date.FormatStyle?

    init(label: String, content: String, format: Date.FormatStyle? = nil) {
        self.label = label
        self.content = content
        self.dateContent = nil
        self.format = format
    }

    init(label: String, dateContent: Date, format: Date.FormatStyle) {
        self.label = label
        self.content = nil
        self.dateContent = dateContent
        self.format = format
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)

            if let dateContent = dateContent, let format = format {
                Text(dateContent, format: format)
                    .font(.body)
            } else if let content = content {
                Text(content.isEmpty ? "N/A" : content)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Divider()
        }
    }
}


