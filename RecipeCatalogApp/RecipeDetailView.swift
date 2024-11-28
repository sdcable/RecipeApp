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
    @State private var isPresented: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe Title
                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Group {
                    DetailRow(label: "Date", dateContent: recipe.date, format: .dateTime.year().month().day())
                    DetailRow(label: "Ingredients", content: recipe.ingredients)
                    DetailRow(label: "Instructions", content: recipe.instructions)
                    DetailRow(label: "Servings", content: "\(recipe.servings)")
                    DetailRow(label: "Difficulty", content: recipe.difficulty)
                    DetailRow(label: "Calories Per Serving", content: "\(recipe.calories_per_serving)")
                    DetailRow(label: "Notes", content: recipe.general_notes)
                }
                // Categories
                if !recipe.categories.isEmpty {
                    Text("Categories")
                        .font(.headline)
                        .padding(.top)
                    ForEach(recipe.categories, id: \.id) { category in
                        Text(category.name)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
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


