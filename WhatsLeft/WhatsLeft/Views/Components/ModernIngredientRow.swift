//
//  ModernIngredientRow.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

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
                .foregroundColor(.appGreen)
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
                        .foregroundColor(.appGreen)
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
                        .foregroundColor(.appGreen)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            // Edit button (pencil)
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.darkYellow)
                    .font(.caption)
                    .padding(8)
                    .background(Color.darkYellow.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
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
    
    return ModernIngredientRow(
        ingredient: sampleIngredient,
        viewModel: KitchenViewModel(),
        onEdit: {}
    )
    .padding()
}
