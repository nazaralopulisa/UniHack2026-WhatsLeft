//
//  Recipe.swift
//  WhatsLeft
//
//  Created by YourName on 14/03/26.
//

import Foundation
import SwiftUI

// MARK: - Recipe Model
struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let difficulty: Difficulty
    let prepTime: Int // in minutes
    let cookTime: Int // in minutes
    let servings: Int
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let tips: [String]?
    let imageName: String? // For app bundle images
    let imageURL: URL?
    var isSaved: Bool = false
    var dateAdded: Date = Date()
    
    // Computed properties
    var totalTime: Int {
        prepTime + cookTime
    }
    
    var formattedTime: String {
        let hours = totalTime / 60
        let minutes = totalTime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // For recipe matching
    func missingIngredients(from availableIngredients: [String]) -> [String] {
        let needed = ingredients.map { $0.name.lowercased() }
        let available = availableIngredients.map { $0.lowercased() }
        
        return needed.filter { ingredient in
            !available.contains { $0.contains(ingredient) || ingredient.contains($0) }
        }
    }
    
    func canMake(with availableIngredients: [String]) -> Bool {
        let missing = missingIngredients(from: availableIngredients)
        return missing.count <= 1 // Allow 1 missing ingredient
    }
}

// MARK: - Difficulty Enum
enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "face.smiling"
        case .medium: return "face.neutral"
        case .hard: return "face.dashed"
        }
    }
}

// MARK: - Recipe Ingredient
struct RecipeIngredient: Identifiable, Codable {
    let id = UUID()
    let name: String
    let quantity: Double
    let unit: String
    let isOptional: Bool
    
    var formattedQuantity: String {
        if quantity == 0 {
            return ""
        }
        
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            let wholeNumber = Int(quantity)
            
            switch unit.lowercased() {
            case "pieces", "piece", "pc", "pcs":
                return "\(wholeNumber)"
            case "grams", "gram", "g":
                return "\(wholeNumber)g"
            case "kilograms", "kilogram", "kg":
                return "\(wholeNumber)kg"
            case "milliliters", "milliliter", "ml":
                return "\(wholeNumber)ml"
            case "liters", "liter", "l":
                return "\(wholeNumber)L"
            case "cups", "cup":
                return "\(wholeNumber) cup\(wholeNumber == 1 ? "" : "s")"
            case "tablespoons", "tablespoon", "tbsp":
                return "\(wholeNumber) tbsp"
            case "teaspoons", "teaspoon", "tsp":
                return "\(wholeNumber) tsp"
            default:
                return "\(wholeNumber) \(unit)"
            }
        } else {
            switch unit.lowercased() {
            case "grams", "gram", "g":
                return String(format: "%.1fg", quantity)
            case "kilograms", "kilogram", "kg":
                return String(format: "%.2fkg", quantity)
            case "milliliters", "milliliter", "ml":
                return String(format: "%.1fml", quantity)
            case "liters", "liter", "l":
                return String(format: "%.2fL", quantity)
            default:
                return String(format: "%.1f %@", quantity, unit)
            }
        }
    }
    
    var displayString: String {
        if isOptional {
            return "\(formattedQuantity) \(name) (optional)"
        } else {
            return "\(formattedQuantity) \(name)"
        }
    }
}

// MARK: - Sample Data
extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "Classic Scrambled Eggs",
            description: "Fluffy, creamy scrambled eggs perfect for breakfast or any time of day.",
            difficulty: .easy,
            prepTime: 2,
            cookTime: 5,
            servings: 2,
            ingredients: [
                RecipeIngredient(name: "Egg", quantity: 4, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Milk", quantity: 2, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Butter", quantity: 1, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Salt", quantity: 0.25, unit: "tsp", isOptional: false),
                RecipeIngredient(name: "Pepper", quantity: 0.25, unit: "tsp", isOptional: true)
            ],
            instructions: [
                "Crack eggs into a bowl and whisk thoroughly until yolks and whites are combined.",
                "Add milk, salt, and pepper. Whisk until frothy.",
                "Melt butter in a non-stick pan over medium-low heat.",
                "Pour in egg mixture and let it set for 30 seconds.",
                "Gently push cooked eggs from edges to center with a spatula.",
                "Continue pushing and folding until eggs are cooked but still soft and creamy.",
                "Remove from heat just before they look done (they'll continue cooking).",
                "Serve immediately with toast."
            ],
            tips: [
                "For extra creamy eggs, add a small knob of butter at the end.",
                "Don't overcook - eggs should be soft and slightly wet.",
                "Use low heat for the fluffiest results."
            ],
            imageName: "scrambled-eggs",
            imageURL: nil,
            isSaved: false
        ),
        
        Recipe(
            name: "Quick Tomato Pasta",
            description: "A simple, delicious pasta sauce made with fresh tomatoes and garlic.",
            difficulty: .easy,
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            ingredients: [
                RecipeIngredient(name: "Pasta", quantity: 400, unit: "grams", isOptional: false),
                RecipeIngredient(name: "Tomatoes", quantity: 6, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Garlic", quantity: 3, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Olive Oil", quantity: 3, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Salt", quantity: 1, unit: "tsp", isOptional: false),
                RecipeIngredient(name: "Basil", quantity: 5, unit: "pieces", isOptional: true),
                RecipeIngredient(name: "Parmesan", quantity: 50, unit: "grams", isOptional: true)
            ],
            instructions: [
                "Bring a large pot of salted water to boil.",
                "Cook pasta according to package instructions until al dente.",
                "While pasta cooks, chop tomatoes and mince garlic.",
                "Heat olive oil in a large pan over medium heat.",
                "Add garlic and sauté until fragrant (about 1 minute).",
                "Add tomatoes and salt. Cook until tomatoes break down (10-12 minutes).",
                "Drain pasta, reserving 1/2 cup pasta water.",
                "Add pasta to the sauce with a splash of pasta water.",
                "Toss to combine. Add basil if using.",
                "Serve with grated parmesan."
            ],
            tips: [
                "Use ripe tomatoes for the best flavor.",
                "Reserve extra pasta water to adjust sauce consistency.",
                "Fresh basil makes a big difference!"
            ],
            imageName: "tomato-pasta",
            imageURL: nil,
            isSaved: false
        ),
        
        Recipe(
            name: "Chicken Stir Fry",
            description: "Quick and healthy stir fry with chicken and vegetables.",
            difficulty: .medium,
            prepTime: 15,
            cookTime: 15,
            servings: 3,
            ingredients: [
                RecipeIngredient(name: "Chicken Breast", quantity: 2, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Rice", quantity: 1.5, unit: "cups", isOptional: false),
                RecipeIngredient(name: "Soy Sauce", quantity: 3, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Garlic", quantity: 2, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Onion", quantity: 1, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Mixed Vegetables", quantity: 2, unit: "cups", isOptional: true),
                RecipeIngredient(name: "Sesame Oil", quantity: 1, unit: "tsp", isOptional: true),
                RecipeIngredient(name: "Ginger", quantity: 1, unit: "tsp", isOptional: true)
            ],
            instructions: [
                "Cook rice according to package instructions.",
                "Cut chicken into bite-sized pieces.",
                "Mince garlic and ginger. Slice onion.",
                "Heat oil in a wok or large pan over high heat.",
                "Add chicken and cook until golden (5-7 minutes).",
                "Remove chicken and set aside.",
                "Add vegetables, garlic, ginger to the pan. Stir fry for 2-3 minutes.",
                "Return chicken to pan. Add soy sauce.",
                "Stir everything together and cook for another minute.",
                "Serve hot over rice."
            ],
            tips: [
                "Have all ingredients ready before you start - stir fry is fast!",
                "Don't overcrowd the pan or food will steam instead of fry.",
                "Use high heat for authentic stir fry texture."
            ],
            imageName: "stir-fry",
            imageURL: nil,
            isSaved: false
        ),
        
        Recipe(
            name: "Simple Pancakes",
            description: "Fluffy homemade pancakes perfect for weekend breakfast.",
            difficulty: .easy,
            prepTime: 10,
            cookTime: 15,
            servings: 4,
            ingredients: [
                RecipeIngredient(name: "Flour", quantity: 1.5, unit: "cups", isOptional: false),
                RecipeIngredient(name: "Milk", quantity: 1.25, unit: "cups", isOptional: false),
                RecipeIngredient(name: "Egg", quantity: 1, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Butter", quantity: 3, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Sugar", quantity: 2, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Baking Powder", quantity: 1, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Salt", quantity: 0.5, unit: "tsp", isOptional: false),
                RecipeIngredient(name: "Maple Syrup", quantity: 0, unit: "pieces", isOptional: true)
            ],
            instructions: [
                "Melt butter and let cool slightly.",
                "In a large bowl, whisk together flour, sugar, baking powder, and salt.",
                "In another bowl, whisk milk, egg, and melted butter.",
                "Pour wet ingredients into dry ingredients and stir until just combined (lumpy is OK).",
                "Heat a non-stick pan over medium heat. Lightly grease with butter.",
                "Pour 1/4 cup batter for each pancake.",
                "Cook until bubbles form on surface (2-3 minutes), then flip.",
                "Cook another 1-2 minutes until golden.",
                "Serve warm with maple syrup."
            ],
            tips: [
                "Don't overmix the batter - lumps are okay!",
                "Let batter rest for 5 minutes for fluffier pancakes.",
                "Keep cooked pancakes warm in a low oven while making the rest."
            ],
            imageName: "pancakes",
            imageURL: nil,
            isSaved: false
        ),
        
        Recipe(
            name: "Vegetable Omelette",
            description: "Protein-packed omelette loaded with vegetables.",
            difficulty: .medium,
            prepTime: 8,
            cookTime: 7,
            servings: 1,
            ingredients: [
                RecipeIngredient(name: "Egg", quantity: 3, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Milk", quantity: 1, unit: "tbsp", isOptional: false),
                RecipeIngredient(name: "Onion", quantity: 0.25, unit: "pieces", isOptional: false),
                RecipeIngredient(name: "Bell Pepper", quantity: 0.25, unit: "pieces", isOptional: true),
                RecipeIngredient(name: "Tomato", quantity: 0.5, unit: "pieces", isOptional: true),
                RecipeIngredient(name: "Cheese", quantity: 30, unit: "grams", isOptional: true),
                RecipeIngredient(name: "Salt", quantity: 0.25, unit: "tsp", isOptional: false),
                RecipeIngredient(name: "Butter", quantity: 1, unit: "tbsp", isOptional: false)
            ],
            instructions: [
                "Finely chop all vegetables.",
                "In a bowl, whisk eggs with milk and salt until frothy.",
                "Heat butter in a non-stick pan over medium heat.",
                "Sauté vegetables for 2-3 minutes until softened.",
                "Pour eggs over vegetables. Let cook without stirring for 2 minutes.",
                "As edges set, gently push them toward center with spatula.",
                "When mostly set but still slightly wet on top, add cheese if using.",
                "Fold omelette in half and slide onto plate."
            ],
            tips: [
                "Use a non-stick pan for easiest flipping.",
                "Don't overcook - omelette should be soft and tender.",
                "Customize with whatever vegetables you have on hand."
            ],
            imageName: "omelette",
            imageURL: nil,
            isSaved: false
        )
    ]
}
