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
    @State private var isShowingScanner = false
    @State private var scannedIngredient = ""
    @State private var showingQuantitySheet = false
    @State private var quantity = ""
    @State private var selectedUnit = "pieces"
    @State private var searchText = ""
    @State private var selectedCategory: IngredientCategory?
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    var filteredIngredients: [Ingredient] {
        var filtered = viewModel.ingredients
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered
    }
    
    var body: some View {
        List {
                    // MARK: - Category Section
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryChip(
                                    title: "All",
                                    icon: "square.grid.2x2",
                                    isSelected: selectedCategory == nil,
                                    action: { selectedCategory = nil }
                                )
                                
                                ForEach(IngredientCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        title: category.rawValue,
                                        icon: category.icon,
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
                        .frame(height: 50)
                    }
                    
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
                                    Text("Tap the scan button to add ingredients")
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
                                IngredientRow(ingredient: ingredient) {
                                    viewModel.toggleIngredient(ingredient)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Scan Button Section
                    Section {
                        Button(action: { isShowingScanner = true }) {
                            Label("Scan Food with AI", systemImage: "camera.viewfinder")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }

                }
                .listStyle(.plain)
                .scrollContentBackground(.visible)
                .background(Color(.systemBackground))
                .navigationTitle("Pantry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Edit mode or add manually
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    if DataScannerViewController.isSupported {
                        FoodCameraView(
                            scannedIngredient: $scannedIngredient,
                            isScanning: $isShowingScanner
                        )
                    } else {
                        // Fallback for devices without camera scan support
                        VStack {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .padding()
                            Text("Camera scanning is not supported on this device")
                                .multilineTextAlignment(.center)
                            Button("OK") {
                                isShowingScanner = false
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        .presentationDetents([.medium])
                    }
                }
                .onChange(of: scannedIngredient) { newValue in
                    if !newValue.isEmpty {
                        showingQuantitySheet = true
                    }
                }
                .sheet(isPresented: $showingQuantitySheet) {
                    QuantityInputView(
                        ingredientName: $scannedIngredient,
                        quantity: $quantity,
                        unit: $selectedUnit,
                        onSave: {
                            if let quantityValue = Double(quantity), !scannedIngredient.isEmpty {
                                let newIngredient = Ingredient(
                                    name: scannedIngredient,
                                    quantity: quantityValue,
                                    unit: selectedUnit,
                                    inStock: true,
                                    category: .other
                                )
                                viewModel.addIngredient(newIngredient)
                                
                                // Reset
                                scannedIngredient = ""
                                quantity = ""
                                selectedUnit = "pieces"
                            }
                        }
                    )
                }

    }
}

// MARK: - Category Chip Component
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Ingredient Row Component
struct IngredientRow: View {
    let ingredient: Ingredient
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Category icon
            Image(systemName: ingredient.category.icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            // Ingredient info
            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .font(.body)
                Text(ingredient.formattedQuantity)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // In stock toggle
            Button(action: onToggle) {
                Image(systemName: ingredient.inStock ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(ingredient.inStock ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        IngredientsView(viewModel: KitchenViewModel())
    }
}
