//
//  KitchenViewModel.swift
//  WhatsLeft
//
//  Created by YourName on 14/03/26.
//

import SwiftUI
import Foundation
import Combine

// MARK: - GroceryItem Model
struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let quantity: Double
    let unit: String

    var displayString: String {
        if quantity == 0 {
            return name
        }
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit) \(name)"
        } else {
            return String(format: "%.1f %@ %@", quantity, unit, name)
        }
    }
}

class KitchenViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var ingredients: [Ingredient] = []
    @Published var savedRecipes: [Recipe] = []
    @Published var groceryList: [GroceryItem] = []
    @Published var searchText: String = ""
    @Published var suggestedRecipes: [Recipe] = []
    @Published var isLoadingRecipes = false
    @Published var recipeError: Error? = nil

    private let recipeService = RecipeService()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var availableIngredients: [String] {
        ingredients.filter { $0.inStock }.map { $0.name }
    }

    var filteredIngredients: [Ingredient] {
        if searchText.isEmpty {
            return ingredients
        } else {
            return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var totalIngredientsCount: Int {
        ingredients.count
    }

    var inStockCount: Int {
        ingredients.filter { $0.inStock }.count
    }

    // MARK: - Initializer
    init() {
        self.ingredients = Ingredient.sampleIngredients
        self.savedRecipes = []
        self.groceryList = []
        Task { await fetchRecipeSuggestions() }
    }

    // MARK: - Ingredient Methods
    func toggleIngredient(_ ingredient: Ingredient) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index].inStock.toggle()
        }
        Task { await fetchRecipeSuggestions() }
    }

    func addIngredient(_ ingredient: Ingredient) {
        if let index = ingredients.firstIndex(where: {
            $0.name.lowercased() == ingredient.name.lowercased()
        }) {
            var existingIngredient = ingredients[index]
            existingIngredient.quantity += ingredient.quantity
            existingIngredient.inStock = true
            ingredients[index] = existingIngredient
        } else {
            ingredients.append(ingredient)
        }
        Task { await fetchRecipeSuggestions() }
    }

    func removeIngredient(at indexSet: IndexSet) {
        ingredients.remove(atOffsets: indexSet)
        Task { await fetchRecipeSuggestions() }
    }

    func updateIngredientQuantity(id: UUID, quantity: Double, unit: String) {
        if let index = ingredients.firstIndex(where: { $0.id == id }) {
            ingredients[index].quantity = quantity
            ingredients[index].unit = unit
        }
        Task { await fetchRecipeSuggestions() }
    }

    func updateIngredientDetails(id: UUID, name: String, category: IngredientCategory) {
        if let index = ingredients.firstIndex(where: { $0.id == id }) {
            ingredients[index].category = category
            ingredients[index].name = name
        }
    }

    func deleteIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
    }

    // MARK: - Recipe Methods
    func getRecipesYouCanMake() -> [Recipe] {
        return SampleData.recipes.filter { $0.canMake(with: availableIngredients) }
    }

    func saveRecipe(_ recipe: Recipe) {
        if !savedRecipes.contains(where: { $0.id == recipe.id }) {
            savedRecipes.append(recipe)
        }
    }

    func unsaveRecipe(_ recipe: Recipe) {
        savedRecipes.removeAll { $0.id == recipe.id }
    }

    @MainActor
    func fetchRecipeSuggestions() async {
        guard !availableIngredients.isEmpty else {
            suggestedRecipes = []
            return
        }

        isLoadingRecipes = true
        recipeError = nil

        do {
            let apiRecipes = try await recipeService.fetchRecipes(byIngredients: availableIngredients)
            let filteredAPIRecipes = apiRecipes.filter { $0.canMake(with: availableIngredients) }
            let localRecipes = getRecipesYouCanMake()
            suggestedRecipes = localRecipes + filteredAPIRecipes
        } catch {
            if Task.isCancelled || (error as? URLError)?.code == .cancelled {
                print("Fetch cancelled – ignoring")
            } else {
                recipeError = error
                suggestedRecipes = getRecipesYouCanMake()
            }
        }

        isLoadingRecipes = false
    }

    // MARK: - Grocery List Methods
    func addToGroceryList(item: GroceryItem) {
        // Merge with existing item if same name and unit
        if let index = groceryList.firstIndex(where: {
            $0.name.lowercased() == item.name.lowercased() && $0.unit == item.unit
        }) {
            let existing = groceryList[index]
            let combined = GroceryItem(
                name: existing.name,
                quantity: existing.quantity + item.quantity,
                unit: existing.unit
            )
            groceryList[index] = combined
        } else {
            groceryList.append(item)
        }
    }

    func addMissingIngredientsFromRecipe(_ recipe: Recipe) {
        let missing = recipe.ingredients.filter { recipeIngredient in
            !availableIngredients.contains { available in
                available.lowercased() == recipeIngredient.name.lowercased()
            }
        }
        for ingredient in missing {
            let groceryItem = GroceryItem(
                name: ingredient.name,
                quantity: ingredient.quantity,
                unit: ingredient.unit
            )
            addToGroceryList(item: groceryItem)
        }
    }

    /// Removes the item from grocery list and adds it to the pantry.
    func purchaseGroceryItem(_ item: GroceryItem) {
        // Remove from grocery list
        groceryList.removeAll { $0.id == item.id }

        // Determine category: use existing ingredient's category if available
        let category: IngredientCategory
        if let existing = ingredients.first(where: { $0.name.lowercased() == item.name.lowercased() }) {
            category = existing.category
        } else {
            category = .other
        }

        // Create new ingredient and add to pantry
        let newIngredient = Ingredient(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            inStock: true,
            category: category
        )
        addIngredient(newIngredient)
    }

    func removeFromGroceryList(at indexSet: IndexSet) {
        groceryList.remove(atOffsets: indexSet)
    }

    func clearGroceryList() {
        groceryList.removeAll()
    }
}

// MARK: - Sample Data
struct SampleData {
    static let recipes = Recipe.sampleRecipes
}
