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
    case dairy = "Dairy"
    case meat = "Meat"
    case grains = "Grains"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case spices = "Spices"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .dairy: return "mug"
        case .meat: return "fork.knife"
        case .grains: return "laurel.leading"
        case .vegetables: return "carrot"
        case .fruits: return "applelogo"
        case .spices: return "sparkles"
        case .other: return "questionmark"
        }
    }
}

// MARK: - Sample Data Extension
extension Ingredient {
    static var sampleIngredients: [Ingredient] {
        [
            Ingredient(name: "Egg", quantity: 12, unit: "pieces", inStock: true, category: .dairy),
            Ingredient(name: "Flour", quantity: 2.5, unit: "kg", inStock: true, category: .grains),
            Ingredient(name: "Milk", quantity: 1, unit: "liter", inStock: true, category: .dairy),
            Ingredient(name: "Salt", quantity: 500, unit: "grams", inStock: true, category: .spices),
            Ingredient(name: "Chicken Breast", quantity: 2, unit: "pieces", inStock: false, category: .meat),
            Ingredient(name: "Rice", quantity: 3, unit: "kg", inStock: true, category: .grains),
            Ingredient(name: "Tomatoes", quantity: 6, unit: "pieces", inStock: true, category: .vegetables),
            Ingredient(name: "Onions", quantity: 3, unit: "pieces", inStock: true, category: .vegetables),
            Ingredient(name: "Garlic", quantity: 1, unit: "pieces", inStock: true, category: .vegetables),
            Ingredient(name: "Butter", quantity: 250, unit: "grams", inStock: true, category: .dairy)
        ]
    }
}
