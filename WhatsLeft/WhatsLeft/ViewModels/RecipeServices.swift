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
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    
    // Ingredients (up to 20)
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    
    // Measurements (up to 20)
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
}

// MARK: - Recipe Service
class RecipeService {
    private let baseURL = "https://www.themealdb.com/api/json/v1/1/"
    
    /// Fetch random recipes (gets FULL recipes with ingredients)
    func fetchRandomRecipes(count: Int = 5) async throws -> [Recipe] {
        var recipes: [Recipe] = []
        
        for _ in 0..<count {
            let urlString = "\(baseURL)random.php"
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
                
                if let meal = response.meals?.first {
                    let recipe = try await fetchRecipeDetails(by: meal.idMeal) ?? convertMealToRecipe(meal)
                    recipes.append(recipe)
                }
                
                // Small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 500_000_000)
                
            } catch {
                print("Error fetching random recipe: \(error)")
            }
        }
        
        return recipes
    }
    
    /// Fetch recipes that contain at least one of the given ingredients.
    func fetchRecipes(byIngredients ingredients: [String]) async throws -> [Recipe] {
        let ingredientParam = ingredients.joined(separator: ",")
        let urlString = "\(baseURL)filter.php?i=\(ingredientParam)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
        
        guard let meals = response.meals else { return [] }
        
        // Fetch details for each recipe (limit to first 5 for performance)
        var recipes: [Recipe] = []
        for meal in meals.prefix(5) {
            if let details = try? await fetchRecipeDetails(by: meal.idMeal) {
                recipes.append(details)
            }
            try await Task.sleep(nanoseconds: 200_000_000)
        }
        
        return recipes
    }
    
    /// Fetch full details for a specific recipe (to get ingredients and instructions).
    func fetchRecipeDetails(by id: String) async throws -> Recipe? {
        let urlString = "\(baseURL)lookup.php?i=\(id)"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
        
        guard let meal = response.meals?.first else { return nil }
        
        return convertMealToRecipe(meal)
    }
    
    /// Convert MealDBMeal to our Recipe model with difficulty estimation
    private func convertMealToRecipe(_ meal: MealDBMeal) -> Recipe {
        // Extract ingredients and measures
        var ingredients: [RecipeIngredient] = []
        
        for i in 1...20 {
            let ingredientKey = "strIngredient\(i)"
            let measureKey = "strMeasure\(i)"
            
            guard let ingredient = meal.value(forKey: ingredientKey) as? String,
                  !ingredient.isEmpty,
                  let measure = meal.value(forKey: measureKey) as? String,
                  !measure.isEmpty else { continue }
            
            let (quantity, unit) = parseMeasure(measure)
            
            ingredients.append(RecipeIngredient(
                name: ingredient,
                quantity: quantity,
                unit: unit,
                isOptional: false
            ))
        }
        
        // Parse instructions
        let instructionsString = meal.value(forKey: "strInstructions") as? String ?? ""
        let instructions = instructionsString
            .components(separatedBy: "\r\n")
            .filter { !$0.isEmpty }
        
        // Calculate difficulty based on complexity
        let difficulty = estimateDifficulty(
            ingredientCount: ingredients.count,
            instructionLength: instructions.joined().count
        )
        
        return Recipe(
            name: meal.strMeal,
            description: "A \(meal.strCategory ?? "delicious") recipe from \(meal.strArea ?? "around the world")",
            difficulty: difficulty,
            prepTime: 0,
            cookTime: 0,
            servings: 4,
            ingredients: ingredients,
            instructions: instructions,
            tips: nil,
            imageName: nil,
            imageURL: URL(string: meal.strMealThumb ?? ""),
            isSaved: false
        )
    }
    
    /// Estimate difficulty based on recipe complexity
    private func estimateDifficulty(ingredientCount: Int, instructionLength: Int) -> Difficulty {
        // Combine both factors for a more nuanced difficulty
        let complexity = (ingredientCount * 10) + (instructionLength / 50)
        
        switch complexity {
        case ..<50:
            return .easy
        case 50..<100:
            return .medium
        default:
            return .hard
        }
    }
    
    // Helper to parse a measure string like "2 cups" or "1 tsp"
    private func parseMeasure(_ measure: String) -> (Double, String) {
        let components = measure.split(separator: " ")
        
        // Try to parse the first component as quantity
        if let first = components.first,
           let quantity = Double(first) {
            let unit = components.dropFirst().joined(separator: " ")
            return (quantity, unit.isEmpty ? "pieces" : unit)
        }
        
        // If no number found, assume quantity is 1
        return (1, measure)
    }
}

// MARK: - Dynamic Member Lookup
extension MealDBMeal {
    func value(forKey key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { $0.label == key }?.value
    }
}
