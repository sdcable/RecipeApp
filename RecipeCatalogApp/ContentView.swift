import SwiftUI
import SwiftData

struct DefaultMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @Query private var categories: [Category]

    @State private var selectedCategory: Category? = nil
    @State private var isPresentingAddRecipeView: Bool = false

    var body: some View {
        NavigationSplitView {
            // Primary Column: Display Categories
            List(categories, id: \.id, selection: $selectedCategory) { category in
                Text(category.name)
            }
            .navigationTitle("Categories")
        }
        content: {
            // Content Column: Display Recipes Filtered by Selected Category
            List {
                let filteredRecipes = selectedCategory == nil
                    ? recipes
                    : recipes.filter { $0.categories.contains(where: { $0.id == selectedCategory!.id }) }

                if filteredRecipes.isEmpty {
                    Text("No recipes available for this category.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink {
                            VStack(alignment: .leading) {
                                Text(recipe.title).font(.title)
                                Text("Ingredients: \(recipe.ingredients)")
                                Text("Instructions: \(recipe.instructions)")
                            }
                            .padding()
                        } label: {
                            Text(recipe.title)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        isPresentingAddRecipeView = true
                    }) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddRecipeView) {
                AddRecipeView(isPresented: $isPresentingAddRecipeView)
            }
            .navigationTitle(selectedCategory?.name ?? "All Recipes")
        }
        detail: {
            Text("Select a Recipe")
        }
        .onAppear {
            populateInitialData()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }

    private func populateInitialData() {
        guard categories.isEmpty && recipes.isEmpty else { return }

        // Create categories
        let category1 = Category(name: "Dinner")
        let category2 = Category(name: "Dessert")
        let category3 = Category(name: "Healthy")
        let category4 = Category(name: "Quick Meals")

        // Create recipes
        let recipe1 = Recipe(
            title: "Spaghetti Bolognese",
            ingredients: "Spaghetti, minced beef, tomato sauce, onion, garlic, olive oil",
            instructions: "Cook pasta, sauté onion and garlic, add minced beef, mix with sauce.",
            searchString: "Spaghetti Bolognese",
            date: Date(),
            time_required: "45 minutes",
            servings: 4,
            difficulty: "Easy",
            calories_per_serving: 450,
            favorite_bool: true,
            general_notes: "A classic Italian dish"
        )
        recipe1.categories.append(category1)

        let recipe2 = Recipe(
            title: "Chocolate Cake",
            ingredients: "Flour, sugar, cocoa powder, eggs, butter, milk",
            instructions: "Mix dry and wet ingredients, bake at 350°F for 30 minutes.",
            searchString: "Chocolate Cake",
            date: Date(),
            time_required: "1 hour",
            servings: 8,
            difficulty: "Medium",
            calories_per_serving: 350,
            favorite_bool: false,
            general_notes: "Great for celebrations"
        )
        recipe2.categories.append(category2)

        let recipe3 = Recipe(
            title: "Grilled Salmon with Vegetables",
            ingredients: "Salmon, broccoli, carrots, olive oil, garlic, lemon",
            instructions: "Grill salmon, steam vegetables, serve together.",
            searchString: "Grilled Salmon with Vegetables",
            date: Date(),
            time_required: "30 minutes",
            servings: 2,
            difficulty: "Easy",
            calories_per_serving: 250,
            favorite_bool: true,
            general_notes: "A healthy and light option"
        )
        recipe3.categories.append(category3)

        let recipe4 = Recipe(
            title: "Avocado Toast",
            ingredients: "Bread, avocado, salt, pepper, olive oil",
            instructions: "Toast bread, mash avocado, spread on toast, season with salt and pepper.",
            searchString: "Avocado Toast",
            date: Date(),
            time_required: "10 minutes",
            servings: 1,
            difficulty: "Easy",
            calories_per_serving: 200,
            favorite_bool: false,
            general_notes: "A quick and nutritious snack"
        )
        recipe4.categories.append(category4)

        modelContext.insert(category1)
        modelContext.insert(category2)
        modelContext.insert(category3)
        modelContext.insert(category4)

        modelContext.insert(recipe1)
        modelContext.insert(recipe2)
        modelContext.insert(recipe3)
        modelContext.insert(recipe4)
    }
}

#Preview {
    DefaultMainView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}



// Modal view for adding a new Recipe
struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var globalCategories: [Category]
    
    @State private var title: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""
    @State private var date: Date = Date()
    @State private var timeRequired: String = ""
    @State private var servings: Int = 1
    @State private var difficulty: String = ""
    @State private var caloriesPerServing: Double = 0.0
    @State private var favoriteBool: Bool = false
    @State private var generalNotes: String = ""
    
    @State private var recipeCategories: [Category] = [] // Categories specific to this recipe
    @State private var newCategoryName: String = "" // Input for creating a new category

    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Title", text: $title)
                    TextField("Ingredients", text: $ingredients, axis: .vertical)
                        .lineLimit(5)
                    TextField("Instructions", text: $instructions, axis: .vertical)
                        .lineLimit(5)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Time Required", text: $timeRequired)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    TextField("Difficulty", text: $difficulty)
                    TextField("Calories Per Serving", value: $caloriesPerServing, format: .number)
                        .keyboardType(.decimalPad)
                    Toggle("Favorite", isOn: $favoriteBool)
                    TextField("General Notes", text: $generalNotes, axis: .vertical)
                        .lineLimit(3)
                }

                Section(header: Text("Assigned Categories")) {
                    if recipeCategories.isEmpty {
                        Text("No categories assigned yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recipeCategories, id: \.id) { category in
                            HStack {
                                Text(category.name)
                                Spacer()
                                Button(action: { removeCategory(category) }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Add Existing Categories")) {
                    ForEach(globalCategories.filter { !recipeCategories.contains($0) }, id: \.id) { category in
                        Button(action: { addCategory(category) }) {
                            HStack {
                                Text(category.name)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                Section(header: Text("Create New Category")) {
                    HStack {
                        TextField("New Category", text: $newCategoryName)
                        Button(action: createCategory) {
                            Label("Add", systemImage: "plus")
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }

                Section {
                    Button("Save Recipe") {
                        saveRecipe()
                        isPresented = false
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty || instructions.isEmpty)
                }
            }
            .navigationTitle("Add New Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    // MARK: - Category Management
    
    /// Adds a category to the recipe's list of categories
    private func addCategory(_ category: Category) {
        recipeCategories.append(category)
    }

    /// Removes a category from the recipe's list of categories
    private func removeCategory(_ category: Category) {
        recipeCategories.removeAll { $0.id == category.id }
    }

    /// Creates a new category and adds it to the recipe and global list
    private func createCategory() {
        let newCategory = Category(name: newCategoryName)
        modelContext.insert(newCategory)
        recipeCategories.append(newCategory) // Add to recipe-specific categories
        newCategoryName = "" // Clear the input field
    }

    // MARK: - Save Recipe

    /// Saves the recipe with its assigned categories
    private func saveRecipe() {
        let searchString = [title, ingredients, instructions].joined(separator: " ")
        let newRecipe = Recipe(
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            searchString: searchString,
            date: date,
            time_required: timeRequired,
            servings: servings,
            difficulty: difficulty,
            calories_per_serving: caloriesPerServing,
            favorite_bool: favoriteBool,
            general_notes: generalNotes
        )

        // Assign categories to the recipe
        for category in recipeCategories {
            newRecipe.categories.append(category)
            category.recipes.append(newRecipe) // Bidirectional relationship
        }

        modelContext.insert(newRecipe)
    }
}

#Preview {
    DefaultMainView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}
