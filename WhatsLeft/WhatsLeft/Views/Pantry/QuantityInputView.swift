//
//  QuantityInputView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//
import SwiftUI

struct QuantityInputView: View {
    @Binding var ingredientName: String
    @Binding var quantity: String
    @Binding var unit: String
    @Binding var category: IngredientCategory
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient") {
                    Text(ingredientName)
                        .font(.headline)
                }
                
                Section("Quantity") {
                    TextField("Amount", text: $quantity)
                        .keyboardType(.decimalPad)
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            HStack {
                                //Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add Quantity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        // dismiss() is called inside onSave now
                    }
                    .disabled(quantity.isEmpty)
                }
            }
        }
    }
}
