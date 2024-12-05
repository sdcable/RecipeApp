import SwiftUI
import SwiftData

struct DefaultMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @Query private var categories: [Category]

    @State private var selectedCategory: Category? = nil
    @State private var isPresentingAddRecipeView: Bool = false
    @State private var searchText: String = ""
    @State private var showFavoritesOnly: Bool = false
    @State private var sortAlphabetically: Bool = false

    var body: some View {
        NavigationSplitView {
            // Primary Column: Display Categories
            categoryList
        }
        content: {
            // Content Column: Display Recipes Filtered by Selected Category
            recipeList
        }
        detail: {
            Text("Select a Recipe")
        }
        .onAppear {
            populateInitialData()
        }
    }

    // MARK: - Category List View
    private var categoryList: some View {
        List {
            // "View All Recipes" NavigationLink
            NavigationLink(destination: AllRecipesView()) {
                Text("View All Recipes")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            // Categories NavigationLinks
            ForEach(categories, id: \.id) { category in
                NavigationLink(destination: FilteredRecipesView(category: category)) {
                    Text(category.name)
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationBarTitle("Categories")
    }



    // MARK: - Recipe List View
    private var recipeList: some View {
        VStack {
            // Filter Toggles
            filterAndSortOptions

            List {
                let filteredRecipes = getFilteredRecipes()
                    .filter { recipe in
                        searchText.isEmpty || recipe.searchString.localizedCaseInsensitiveContains(searchText)
                    }

                if filteredRecipes.isEmpty {
                    Text("No recipes available for this category.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            recipeRow(recipe: recipe)
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
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }

    // MARK: - Recipe Row View
    // MARK: - Recipe Row View
    private func recipeRow(recipe: Recipe) -> some View {
        HStack {
            Button(action: {
                toggleFavorite(for: recipe)
            }) {
                Image(systemName: recipe.favorite_bool ? "star.fill" : "star")
                    .foregroundColor(recipe.favorite_bool ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle()) // Prevents row selection when clicking the star

            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(recipe.ingredients)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func toggleFavorite(for recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            withAnimation {
                recipes[index].favorite_bool.toggle()
            }
        }
    }


    // MARK: - Filtering Recipes
    private func getFilteredRecipes() -> [Recipe] {
        var result = selectedCategory == nil
            ? recipes // No category selected, return all recipes
            : recipes.filter { recipe in
                recipe.categories.contains(where: { $0.id == selectedCategory!.id })
            }

        if showFavoritesOnly {
            result = result.filter { $0.favorite_bool }
        }

        if sortAlphabetically {
            result = result.sorted { $0.title < $1.title }
        }

        return result
    }

    // MARK: - Filter and Sort Options
    private var filterAndSortOptions: some View {
        HStack {
            Toggle("Favorites Only", isOn: $showFavoritesOnly)
                .toggleStyle(.switch)
            Spacer()
            Toggle("Sort A-Z", isOn: $sortAlphabetically)
                .toggleStyle(.switch)
        }
        .padding([.horizontal, .top])
    }

    // MARK: - Deleting Items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }

    // MARK: - Initial Data Population
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
        
        let recipe5 = Recipe(
            title: "Spaghetti Carbonara",
            ingredients: "Spaghetti, eggs, Parmesan cheese, pancetta, black pepper",
            instructions: "Cook spaghetti, whisk eggs and cheese, cook pancetta, combine all with pasta and season with black pepper.",
            searchString: "Spaghetti Carbonara",
            date: Date(),
            time_required: "25 minutes",
            servings: 4,
            difficulty: "Medium",
            calories_per_serving: 400,
            favorite_bool: false,
            general_notes: "A classic Italian pasta dish that's creamy and flavorful."
        )
        recipe5.categories.append(category3)

        let recipe6 = Recipe(
            title: "Grilled Chicken Salad",
            ingredients: "Chicken breast, mixed greens, cherry tomatoes, cucumber, olive oil, lemon juice",
            instructions: "Grill chicken, chop vegetables, toss with olive oil and lemon juice, top with sliced chicken.",
            searchString: "Grilled Chicken Salad",
            date: Date(),
            time_required: "20 minutes",
            servings: 2,
            difficulty: "Easy",
            calories_per_serving: 250,
            favorite_bool: false,
            general_notes: "A light and healthy meal packed with protein."
        )
        recipe6.categories.append(category4)

        let recipe7 = Recipe(
            title: "Chocolate Chip Cookies",
            ingredients: "Flour, butter, sugar, brown sugar, eggs, vanilla extract, chocolate chips, baking soda, salt",
            instructions: "Mix dry ingredients, cream butter and sugars, add eggs and vanilla, combine, stir in chocolate chips, bake at 350°F for 10-12 minutes.",
            searchString: "Chocolate Chip Cookies",
            date: Date(),
            time_required: "30 minutes",
            servings: 24,
            difficulty: "Medium",
            calories_per_serving: 150,
            favorite_bool: true,
            general_notes: "Soft and chewy cookies perfect for any occasion."
        )
        recipe7.categories.append(category2)

        let recipe8 = Recipe(
            title: "Vegetable Stir Fry",
            ingredients: "Mixed vegetables, soy sauce, garlic, ginger, sesame oil, rice (optional)",
            instructions: "Chop vegetables, sauté in sesame oil, add garlic and ginger, stir in soy sauce, serve with rice if desired.",
            searchString: "Vegetable Stir Fry",
            date: Date(),
            time_required: "15 minutes",
            servings: 3,
            difficulty: "Easy",
            calories_per_serving: 200,
            favorite_bool: false,
            general_notes: "A versatile dish that can be customized with your favorite vegetables."
        )
        recipe8.categories.append(category4)


        modelContext.insert(category1)
        modelContext.insert(category2)
        modelContext.insert(category3)
        modelContext.insert(category4)

        modelContext.insert(recipe1)
        modelContext.insert(recipe2)
        modelContext.insert(recipe3)
        modelContext.insert(recipe4)
        modelContext.insert(recipe5)
        modelContext.insert(recipe6)
        modelContext.insert(recipe7)
        modelContext.insert(recipe8)
    }
}


#Preview {
    DefaultMainView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}

struct AllRecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @State private var isPresentingAddRecipeView: Bool = false
    
    @State private var searchText: String = ""
    @State private var showFavoritesOnly: Bool = false
    @State private var sortAlphabetically: Bool = false
    
    var body: some View {
        VStack {
            filterAndSortOptions

            List {
                let filteredRecipes = getFilteredRecipes()
                    .filter { recipe in
                        searchText.isEmpty || recipe.searchString.localizedCaseInsensitiveContains(searchText)
                    }

                if filteredRecipes.isEmpty {
                    Text("No recipes available.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            recipeRow(recipe: recipe)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .sheet(isPresented: $isPresentingAddRecipeView) {
                AddRecipeView(isPresented: $isPresentingAddRecipeView)
            }
            .navigationTitle("All Recipes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
    
    private var filterAndSortOptions: some View {
        HStack {
            Toggle("Favorites Only", isOn: $showFavoritesOnly)
                .toggleStyle(.switch)
            Spacer()
            Toggle("Sort A-Z", isOn: $sortAlphabetically)
                .toggleStyle(.switch)
        }
        .padding([.horizontal, .top])
    }
    
    private func getFilteredRecipes() -> [Recipe] {
        var result = recipes

        if showFavoritesOnly {
            result = result.filter { $0.favorite_bool }
        }

        if sortAlphabetically {
            result = result.sorted { $0.title < $1.title }
        }

        return result
    }
    
    private func recipeRow(recipe: Recipe) -> some View {
        HStack {
            Button(action: {
                toggleFavorite(for: recipe)
            }) {
                Image(systemName: recipe.favorite_bool ? "star.fill" : "star")
                    .foregroundColor(recipe.favorite_bool ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())

            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(recipe.ingredients)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func toggleFavorite(for recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            withAnimation {
                recipes[index].favorite_bool.toggle()
            }
        }
    }
    
    // MARK: - Deleting Items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }
}


struct FilteredRecipesView: View {
    @Environment(\.modelContext) private var modelContext
    let category: Category
    @Query private var recipes: [Recipe]
    @State private var isPresentingAddRecipeView: Bool = false
    
    @State private var searchText: String = ""
    @State private var showFavoritesOnly: Bool = false
    @State private var sortAlphabetically: Bool = false
    
    var body: some View {
        VStack {
            filterAndSortOptions

            List {
                let filteredRecipes = getFilteredRecipes()
                    .filter { recipe in
                        searchText.isEmpty || recipe.searchString.localizedCaseInsensitiveContains(searchText)
                    }

                if filteredRecipes.isEmpty {
                    Text("No recipes available for this category.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            recipeRow(recipe: recipe)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .sheet(isPresented: $isPresentingAddRecipeView) {
                AddRecipeView(isPresented: $isPresentingAddRecipeView)
            }
            .navigationTitle(category.name)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
    
    // Reuse filter and sort options from the main view
    private var filterAndSortOptions: some View {
        HStack {
            Toggle("Favorites Only", isOn: $showFavoritesOnly)
                .toggleStyle(.switch)
            Spacer()
            Toggle("Sort A-Z", isOn: $sortAlphabetically)
                .toggleStyle(.switch)
        }
        .padding([.horizontal, .top])
    }
    
    private func getFilteredRecipes() -> [Recipe] {
        var result = recipes.filter { recipe in
            recipe.categories.contains(where: { $0.id == category.id })
        }

        if showFavoritesOnly {
            result = result.filter { $0.favorite_bool }
        }

        if sortAlphabetically {
            result = result.sorted { $0.title < $1.title }
        }

        return result
    }
    
    private func recipeRow(recipe: Recipe) -> some View {
        HStack {
            Button(action: {
                toggleFavorite(for: recipe)
            }) {
                Image(systemName: recipe.favorite_bool ? "star.fill" : "star")
                    .foregroundColor(recipe.favorite_bool ? .yellow : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())

            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(recipe.ingredients)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func toggleFavorite(for recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            withAnimation {
                recipes[index].favorite_bool.toggle()
            }
        }
    }
    
    // MARK: - Deleting Items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }
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
    var recipeToEdit: Recipe?

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
                    Button(recipeToEdit == nil ? "Save Recipe" : "Update Recipe") {
                        saveRecipe()
                        isPresented = false
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty || instructions.isEmpty)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(recipeToEdit == nil ? "Add New Recipe" : "Edit Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                if let recipeToEdit = recipeToEdit {
                    loadRecipeDetails(recipeToEdit)
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

    // MARK: - Load Recipe Details

    /// Populates the view with details from an existing recipe
    private func loadRecipeDetails(_ recipe: Recipe) {
        title = recipe.title
        ingredients = recipe.ingredients
        instructions = recipe.instructions
        date = recipe.date
        timeRequired = recipe.time_required
        servings = recipe.servings
        difficulty = recipe.difficulty
        caloriesPerServing = recipe.calories_per_serving
        favoriteBool = recipe.favorite_bool
        generalNotes = recipe.general_notes
        recipeCategories = recipe.categories
    }

    // MARK: - Save Recipe

    /// Saves or updates the recipe
    private func saveRecipe() {
        let searchString = [title, ingredients, instructions].joined(separator: " ")
        
        if let recipeToEdit = recipeToEdit {
            // Update existing recipe
            recipeToEdit.title = title
            recipeToEdit.ingredients = ingredients
            recipeToEdit.instructions = instructions
            recipeToEdit.searchString = searchString
            recipeToEdit.date = date
            recipeToEdit.time_required = timeRequired
            recipeToEdit.servings = servings
            recipeToEdit.difficulty = difficulty
            recipeToEdit.calories_per_serving = caloriesPerServing
            recipeToEdit.favorite_bool = favoriteBool
            recipeToEdit.general_notes = generalNotes
            recipeToEdit.categories = recipeCategories
        } else {
            // Create a new recipe
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

            // Assign categories to the new recipe
            for category in recipeCategories {
                newRecipe.categories.append(category)
                category.recipes.append(newRecipe) // Bidirectional relationship
            }
            modelContext.insert(newRecipe)
        }
    }
}




#Preview {
    DefaultMainView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}
