//
//  IngredientsView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI
import VisionKit

struct IngredientsView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String? = "All"
    
    // Manual add states
    @State private var showingAddIngredient = false
    @State private var newIngredientName = ""
    @State private var newIngredientQuantity = ""
    @State private var newIngredientUnit = "pieces"
    @State private var newIngredientCategory: IngredientCategory = .other
    
    // Edit states
    @State private var showingEditSheet = false
    @State private var editingIngredient: Ingredient?
    @State private var editName = ""
    @State private var editQuantity = ""
    @State private var editUnit = "pieces"
    @State private var editCategory: IngredientCategory = .other
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    // Categories from your mockup
    let categories = ["All", "Dairy", "Meat", "Grains", "Vegetables", "Fruits", "Spices"]
    
    // Map categories to IngredientCategory
    func categoryFilter(_ category: String) -> IngredientCategory? {
        switch category {
        case "Dairy": return .dairy
        case "Meat": return .meat
        case "Grains": return .grains
        case "Vegetables": return .vegetables
        case "Fruits": return .fruits
        case "Spices": return .spices
        default: return nil
        }
    }
    
    var filteredIngredients: [Ingredient] {
        var filtered = viewModel.ingredients
        
        // Apply category filter
        if let category = selectedCategory, category != "All" {
            if let enumCategory = categoryFilter(category) {
                filtered = filtered.filter { $0.category == enumCategory }
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered
    }
    
    var body: some View {
        List {
            // MARK: - Search Section
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search ingredients...", text: $searchText)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            
            // MARK: - Category Section
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                count: category == "All" ? viewModel.ingredients.count :
                                       viewModel.ingredients.filter { categoryFilter(category) == $0.category }.count,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            
            // MARK: - Ingredients Section
            Section {
                if filteredIngredients.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "carrot")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No ingredients found")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Tap the + button to add ingredients manually")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 40)
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredIngredients) { ingredient in
                        ModernIngredientRow(
                            ingredient: ingredient,
                            viewModel: viewModel,
                            onEdit: {
                                editingIngredient = ingredient
                                editName = ingredient.name
                                editCategory = ingredient.category
                                showingEditSheet = true
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.visible)
        .background(Color(.systemBackground))
        .navigationTitle("Pantry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Left: Item count
            ToolbarItem(placement: .navigationBarLeading) {
                Text("\(filteredIngredients.count) items")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Right: Manual Add Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddIngredient = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
        }
        
        // Manual Add Sheet
        .sheet(isPresented: $showingAddIngredient) {
            NavigationStack {
                Form {
                    Section("Ingredient Details") {
                        TextField("Name", text: $newIngredientName)
                            .textInputAutocapitalization(.words)
                        
                        HStack {
                            TextField("Quantity", text: $newIngredientQuantity)
                                .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: $newIngredientUnit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .frame(width: 100)
                        }
                        
                        Picker("Category", selection: $newIngredientCategory) {
                            ForEach(IngredientCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon).tag(category)
                            }
                        }
                    }
                }
                .navigationTitle("Add Ingredient")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddIngredient = false
                            resetManualForm()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let quantityValue = Double(newIngredientQuantity), !newIngredientName.isEmpty {
                                let ingredient = Ingredient(
                                    name: newIngredientName,
                                    quantity: quantityValue,
                                    unit: newIngredientUnit,
                                    inStock: true,
                                    category: newIngredientCategory
                                )
                                viewModel.addIngredient(ingredient)
                                showingAddIngredient = false
                                resetManualForm()
                            }
                        }
                        .disabled(newIngredientName.isEmpty || newIngredientQuantity.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        
        // Edit Name/Category/Quantity Sheet
        .sheet(isPresented: $showingEditSheet) {
            if let ingredient = editingIngredient {
                NavigationView {
                    Form {
                        Section(header: Text("Ingredient Details")) {
                            // Name field
                            TextField("Name", text: $editName)
                                .textInputAutocapitalization(.words)
                            
                            // Quantity with manual input
                            HStack {
                                Text("Quantity")
                                    .foregroundColor(.gray)
                                    .frame(width: 80, alignment: .leading)
                                                    
                                HStack(spacing: 8) {
                                    // Quantity text field
                                    TextField("0", text: $editQuantity)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .multilineTextAlignment(.center)
                                                        
                                    // Unit picker
                                    Picker("Unit", selection: $editUnit) {
                                        ForEach(units, id: \.self) { unit in
                                            Text(unit).tag(unit)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 90)
                                    //.background(Color.gray.opacity(0.1))
                                    //.cornerRadius(6)
                                }
                                                    
                                Spacer()
                            }
                            
                            // Category picker
                            Picker("Category", selection: $editCategory) {
                                ForEach(IngredientCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }.tag(category)
                                }
                            }
                        }
                        
                        // Quick quantity presets
                        Section(header: Text("Quick Set")) {
                            HStack {
                                ForEach([0.5, 1, 2, 5], id: \.self) { value in
                                    Button(action: {
                                        editQuantity = String(format: "%.1f", value)
                                    }) {
                                        Text(String(format: "%.1f", value))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.orange.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    if value != 5 {
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        Section {
                            Button(role: .destructive) {
                                viewModel.deleteIngredient(id: ingredient.id)
                                showingEditSheet = false
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Delete Ingredient")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .navigationTitle("Edit \(ingredient.name)")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingEditSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                // Save name and category
                                viewModel.updateIngredientDetails(
                                    id: ingredient.id,
                                    name: editName,
                                    category: editCategory
                                )
                                
                                // Save quantity if valid
                                if let quantityValue = Double(editQuantity) {
                                    viewModel.updateIngredientQuantity(
                                        id: ingredient.id,
                                        quantity: quantityValue,
                                        unit: editUnit
                                    )
                                }
                                
                                showingEditSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.height(450)])
                .onAppear {
                    // Initialize edit fields when sheet appears
                    editName = ingredient.name
                    editQuantity = String(format: "%.1f", ingredient.quantity)
                    editUnit = ingredient.unit
                    editCategory = ingredient.category
                }
            }
        }
    }
    
    func resetManualForm() {
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = "pieces"
        newIngredientCategory = .other
    }
}

// MARK: - Modern Ingredient Row with Plus/Minus Buttons
struct ModernIngredientRow: View {
    let ingredient: Ingredient
    let viewModel: KitchenViewModel
    let onEdit: () -> Void
    
    @State private var quantity: Double
    
    init(ingredient: Ingredient, viewModel: KitchenViewModel, onEdit: @escaping () -> Void) {
        self.ingredient = ingredient
        self.viewModel = viewModel
        self.onEdit = onEdit
        _quantity = State(initialValue: ingredient.quantity)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: ingredient.category.icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            // Ingredient name and unit
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(ingredient.unit)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Quantity controls
            HStack(spacing: 8) {
                // Minus button
                Button {
                    if quantity > 0.1 {
                        quantity -= 1
                        viewModel.updateIngredientQuantity(
                            id: ingredient.id,
                            quantity: quantity,
                            unit: ingredient.unit
                        )
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Quantity display
                Text(String(format: "%.0f", quantity))
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30)
                
                // Plus button
                Button {
                    quantity += 1
                    viewModel.updateIngredientQuantity(
                        id: ingredient.id,
                        quantity: quantity,
                        unit: ingredient.unit
                    )
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            // Edit button (pencil)
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Category Chip with Count
struct CategoryChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                Text("(\(count))")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    NavigationStack {
        IngredientsView(viewModel: KitchenViewModel())
    }
}
