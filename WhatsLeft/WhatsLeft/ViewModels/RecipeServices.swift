//
//  RecipeServices.swift
//  WhatsLeft
//
//  Created by Shi Lynn on 14/03/2026.
//

import Foundation

// MARK: - API Response Models
struct MealDBResponse: Codable {
    let meals: [MealDBMeal]?
}

struct MealDBMeal: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
}

// MARK: - Recipe Service
class RecipeService {
    private let baseURL = "https://www.themealdb.com/api/json/v1/1/"
    
    /// Fetch recipes that contain at least one of the given ingredients.
    func fetchRecipes(byIngredients ingredients: [String]) async throws -> [Recipe] {
        // TheMealDB expects comma‑separated ingredient names
        let ingredientParam = ingredients.joined(separator: ",")
        let urlString = "\(baseURL)filter.php?i=\(ingredientParam)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
        
        // Convert MealDBMeal to our Recipe model
        let recipes = response.meals?.map { meal in
            Recipe(
                name: meal.strMeal,
                description: "Recipe from TheMealDB",
                difficulty: .medium,          // default difficulty
                prepTime: 0,
                cookTime: 0,
                servings: 1,
                ingredients: [],                // we'll fetch details on demand
                instructions: [],
                tips: nil,
                imageName: nil,
                imageURL: URL(string: meal.strMealThumb ?? ""),
                isSaved: false
            )
        } ?? []
        
        return recipes
    }
    
    /// Fetch full details for a specific recipe (to get ingredients and instructions).
    func fetchRecipeDetails(by id: String) async throws -> Recipe? {
        let urlString = "\(baseURL)lookup.php?i=\(id)"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
        
        guard let meal = response.meals?.first else { return nil }
        
        // Extract ingredients and measures (TheMealDB provides up to 20)
        var ingredients: [RecipeIngredient] = []
        for i in 1...20 {
            let ingredientKey = "strIngredient\(i)"
            let measureKey = "strMeasure\(i)"
            
            guard let ingredient = meal.value(forKey: ingredientKey) as? String,
                  !ingredient.isEmpty,
                  let measure = meal.value(forKey: measureKey) as? String,
                  !measure.isEmpty else { continue }
            
            // Parse quantity and unit from measure string (simplified)
            let (quantity, unit) = parseMeasure(measure)
            
            ingredients.append(RecipeIngredient(
                name: ingredient,
                quantity: quantity,
                unit: unit,
                isOptional: false
            ))
        }
        
        // Split instructions by newline
        let instructions = (meal.value(forKey: "strInstructions") as? String)?
            .components(separatedBy: "\r\n")
            .filter { !$0.isEmpty } ?? []
        
        return Recipe(
            name: meal.strMeal,
            description: "Recipe from TheMealDB",
            difficulty: .medium,
            prepTime: 0,
            cookTime: 0,
            servings: 1,
            ingredients: ingredients,
            instructions: instructions,
            tips: nil,
            imageName: nil,
            imageURL: URL(string: meal.strMealThumb ?? ""),
            isSaved: false
        )
    }
    
    // Helper to parse a measure string like "2 cups" or "1 tsp"
    private func parseMeasure(_ measure: String) -> (Double, String) {
        let components = measure.split(separator: " ")
        guard components.count >= 2,
              let quantity = Double(components[0]) else {
            return (0, measure)
        }
        let unit = components.dropFirst().joined(separator: " ")
        return (quantity, unit)
    }
}

// Needed for dynamic member lookup (used in fetchRecipeDetails)
extension MealDBMeal {
    func value(forKey key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { $0.label == key }?.value
    }
}
