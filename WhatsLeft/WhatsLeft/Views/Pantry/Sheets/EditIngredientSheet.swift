//
//  EditIngredientSheet.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

struct EditIngredientSheet: View {
    let ingredient: Ingredient
    @ObservedObject var viewModel: KitchenViewModel
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var quantity: String
    @State private var unit: String
    @State private var category: IngredientCategory
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    init(ingredient: Ingredient, viewModel: KitchenViewModel, isPresented: Binding<Bool>) {
        self.ingredient = ingredient
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // Initialize state with ingredient values
        _name = State(initialValue: ingredient.name)
        _quantity = State(initialValue: String(format: "%.1f", ingredient.quantity))
        _unit = State(initialValue: ingredient.unit)
        _category = State(initialValue: ingredient.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    // Name field
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    // Quantity with manual input
                    HStack {
                        Text("Quantity")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("Amount", text: $quantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        
                        Picker("", selection: $unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                    }
                    
                    // Category picker
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            HStack {
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
                                quantity = String(format: "%.1f", value)
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
                        isPresented = false
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
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save name and category
                        viewModel.updateIngredientDetails(
                            id: ingredient.id,
                            name: name,
                            category: category
                        )
                        
                        // Save quantity if valid
                        if let quantityValue = Double(quantity) {
                            viewModel.updateIngredientQuantity(
                                id: ingredient.id,
                                quantity: quantityValue,
                                unit: unit
                            )
                        }
                        
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(480)])
    }
            
}

#Preview {
    let sampleIngredient = Ingredient(
        name: "Milk",
        quantity: 2,
        unit: "liters",
        inStock: true,
        category: .dairy
    )
    
    return EditIngredientSheet(
        ingredient: sampleIngredient,
        viewModel: KitchenViewModel(),
        isPresented: .constant(true)
    )
}
