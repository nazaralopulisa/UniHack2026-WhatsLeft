//
//  AddIngredientSheet.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

struct AddIngredientSheet: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var unit = "pieces"
    @State private var category: IngredientCategory = .other
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .labelsHidden()
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        resetForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let quantityValue = Double(quantity), !name.isEmpty {
                            let ingredient = Ingredient(
                                name: name,
                                quantity: quantityValue,
                                unit: unit,
                                inStock: true,
                                category: category
                            )
                            viewModel.addIngredient(ingredient)
                            isPresented = false
                            resetForm()
                        }
                    }
                    .disabled(name.isEmpty || quantity.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func resetForm() {
        name = ""
        quantity = ""
        unit = "pieces"
        category = .other
    }
}

#Preview {
    AddIngredientSheet(
        viewModel: KitchenViewModel(),
        isPresented: .constant(true)
    )
}
