//
//  KitchenViewModel.swift
//  WhatsLeft
//
//  Created by YourName on 14/03/26.
//

import SwiftUI
import Foundation
import Combine

class KitchenViewModel: ObservableObject {
    
    // MARK: - Published Properties
    // These notify the view when they change
    @Published var ingredients: [Ingredient] = []
    @Published var savedRecipes: [Recipe] = []
    @Published var groceryList: [String] = []
    @Published var searchText: String = ""
    
    // MARK: - Initializer
    init() {
        // Load saved data or use sample data
        self.ingredients = Ingredient.sampleIngredients
        self.savedRecipes = []
        self.groceryList = []
    }
    
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
    
    // MARK: - Ingredient Methods
    func toggleIngredient(_ ingredient: Ingredient) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index].inStock.toggle()
        }
    }
    
    func addIngredient(_ ingredient: Ingredient) {  // Capital I in Ingredient
        // Check if ingredient already exists (case insensitive)
        if let index = ingredients.firstIndex(where: {
            $0.name.lowercased() == ingredient.name.lowercased()
        }) {
            // Update existing ingredient
            var existingIngredient = ingredients[index]
            existingIngredient.quantity += ingredient.quantity
            existingIngredient.inStock = true
            ingredients[index] = existingIngredient
        } else {
            // Add new ingredient
            ingredients.append(ingredient)
        }
    }
    
    func removeIngredient(at indexSet: IndexSet) {
        ingredients.remove(atOffsets: indexSet)
    }
    
    func updateIngredientQuantity(id: UUID, newQuantity: Double) {
        if let index = ingredients.firstIndex(where: { $0.id == id }) {
            ingredients[index].quantity = newQuantity
        }
    }
    
    // MARK: - Recipe Methods
    func getRecipesYouCanMake() -> [Recipe] {
        // This will be expanded later with actual recipe matching
        return SampleData.recipes.filter { recipe in
            let missingIngredients = recipe.ingredients.filter { recipeIngredient in
                !availableIngredients.contains { available in
                    available.lowercased() == recipeIngredient.name.lowercased()
                }
            }
            return missingIngredients.count <= 1 // Allow 1 missing ingredient
        }
    }
    
    func saveRecipe(_ recipe: Recipe) {
        if !savedRecipes.contains(where: { $0.id == recipe.id }) {
            savedRecipes.append(recipe)
        }
    }
    
    func unsaveRecipe(_ recipe: Recipe) {
        savedRecipes.removeAll { $0.id == recipe.id }
    }
    
    // MARK: - Grocery List Methods
    func addToGroceryList(item: String) {
        if !groceryList.contains(item) {
            groceryList.append(item)
        }
    }
    
    func addMissingIngredientsFromRecipe(_ recipe: Recipe) {
        let missing = recipe.ingredients.filter { recipeIngredient in
            !availableIngredients.contains { available in
                available.lowercased() == recipeIngredient.name.lowercased()
            }
        }
        
        for item in missing {
            addToGroceryList(item: item.name)
        }
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
