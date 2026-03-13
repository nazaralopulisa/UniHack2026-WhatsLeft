import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String  // Just use this directly
    var quantity: Double
    var unit: String
    var inStock: Bool
    var category: IngredientCategory
    
    // Formatted display string
    var formattedQuantity: String {
        if quantity == 0 {
            return "Out of stock"
        }
        
        // Handle whole numbers without decimals
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            let wholeNumber = Int(quantity)
            
            switch unit.lowercased() {
            case "pieces", "piece", "pc", "pcs":
                return "\(wholeNumber) \(wholeNumber == 1 ? name : name + "s")"
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
            // Handle decimal numbers
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
    
    // Custom initializer
    init(name: String, quantity: Double, unit: String, inStock: Bool, category: IngredientCategory) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.inStock = inStock
        self.category = category
    }
}

enum IngredientCategory: String, CaseIterable {
    case produce = "Produce"      // Fruits, vegetables
    case dairy = "Dairy"           // Milk, cheese, eggs
    case meat = "Meat"             // Chicken, beef, pork
    case seafood = "Seafood"       // Fish, shrimp
    case pantry = "Pantry"         // Rice, pasta, canned goods
    case spices = "Spices"         // Salt, pepper, herbs
    case baking = "Baking"         // Flour, sugar, baking powder
    case condiments = "Condiments" // Ketchup, mustard, sauces
    case frozen = "Frozen"         // Frozen vegetables, ice cream
    case beverages = "Beverages"   // Drinks, milk alternatives
    case other = "Other"           // Miscellaneous
    
    var icon: String {
        switch self {
        case .produce: return "leaf"
        case .dairy: return "drop"
        case .meat: return "hare"
        case .seafood: return "fish"
        case .pantry: return "cabinet"
        case .spices: return "sparkles"
        case .baking: return "oven"
        case .condiments: return "bottle"
        case .frozen: return "snowflake"
        case .beverages: return "mug"
        case .other: return "questionmark"
        }
    }
}

// MARK: - Sample Data Extension
extension Ingredient {
    static var sampleIngredients: [Ingredient] {
        [
            Ingredient(name: "Egg", quantity: 12, unit: "pieces", inStock: true, category: .dairy),
            Ingredient(name: "Flour", quantity: 2.5, unit: "kg", inStock: true, category: .baking),
            Ingredient(name: "Milk", quantity: 1, unit: "liter", inStock: true, category: .dairy),
            Ingredient(name: "Salt", quantity: 500, unit: "grams", inStock: true, category: .spices),
            Ingredient(name: "Chicken Breast", quantity: 2, unit: "pieces", inStock: false, category: .meat),
            Ingredient(name: "Rice", quantity: 3, unit: "kg", inStock: true, category: .pantry),
            Ingredient(name: "Tomatoes", quantity: 6, unit: "pieces", inStock: true, category: .produce),
            Ingredient(name: "Onions", quantity: 3, unit: "pieces", inStock: true, category: .produce),
            Ingredient(name: "Garlic", quantity: 1, unit: "pieces", inStock: true, category: .produce),
            Ingredient(name: "Butter", quantity: 250, unit: "grams", inStock: true, category: .dairy)
        ]
    }
}
