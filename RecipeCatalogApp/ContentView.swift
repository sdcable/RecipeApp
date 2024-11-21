import SwiftUI
import SwiftData

struct DefaultMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    
    @State private var searchString: String = ""
    @State private var isPresentingAddRecipeView: Bool = false // Tracks modal visibility

    var body: some View {
        NavigationSplitView {
            List {
                Button("Browse All Recipes") {
                    // Add functionality here if needed
                }
                Button("Show Favorites") {
                    // Add functionality here if needed
                }
                Text("Item three")
            }
        }
        content: {
            List {
                ForEach(recipes) { recipe in
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        isPresentingAddRecipeView = true // Show modal
                    }) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchString) // Add searchable functionality later
            .sheet(isPresented: $isPresentingAddRecipeView) {
                AddRecipeView(isPresented: $isPresentingAddRecipeView)
            }
        } detail: {
            Text("Select a Recipe")
        }
    }

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
    @Binding var isPresented: Bool // Controls dismissal of the modal
    
    @State private var title: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Title", text: $title)
                    TextField("Ingredients", text: $ingredients)
                    TextField("Instructions", text: $instructions)
                }
            }
            .navigationTitle("Add Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addNewRecipe()
                        isPresented = false
                    }
                }
            }
        }
    }

    private func addNewRecipe() {
        let concatedSearchString = [title, ingredients, instructions].joined(separator: " ")
        let newRecipe = Recipe(title: title, ingredients: ingredients, instructions: instructions, searchString: concatedSearchString)
        modelContext.insert(newRecipe)
    }
}

#Preview {
    DefaultMainView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
