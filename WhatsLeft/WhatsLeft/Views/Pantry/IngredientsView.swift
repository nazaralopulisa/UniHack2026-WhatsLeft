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
    
    // Sheet states
    @State private var showingAddIngredient = false
    @State private var showingEditSheet = false
    @State private var editingIngredient: Ingredient?
    
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
            // Search Section
            Section {
                SearchBar(text: $searchText, placeholder: "Search ingredients...")
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            
            // Category Section
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
            
            // Ingredients Section
            Section {
                if filteredIngredients.isEmpty {
                    EmptyStateView()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredIngredients) { ingredient in
                        ModernIngredientRow(
                            ingredient: ingredient,
                            viewModel: viewModel,
                            onEdit: {
                                editingIngredient = ingredient
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
            ToolbarItem(placement: .navigationBarLeading) {
                Text("\(filteredIngredients.count) items")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
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
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientSheet(
                viewModel: viewModel,
                isPresented: $showingAddIngredient
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            if let ingredient = editingIngredient {
                EditIngredientSheet(
                    ingredient: ingredient,
                    viewModel: viewModel,
                    isPresented: $showingEditSheet
                )
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
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
    }
}

#Preview {
    NavigationStack {
        IngredientsView(viewModel: KitchenViewModel())
    }
}
