//
//  GroceryListView.swift
//  WhatsLeft
//
//  Created by Nazara on 15/03/26.
//

import SwiftUI

struct GroceryListView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Binding var selectedTab: Int
    @State private var expandedSections: Set<UUID> = []
    @State private var checkedItems = Set<UUID>()
    @State private var alertMessage: String?
    @State private var viewMode: ViewMode = .byRecipe
    
    // Group grocery items by recipe
    private var recipeSections: [RecipeSection] {
        // Group by recipeId (nil items go to "Other")
        let grouped = Dictionary(grouping: viewModel.groceryList) { $0.recipeId }
        
        var sections: [RecipeSection] = []
        
        // Add sections with recipe IDs
        for (recipeId, items) in grouped where recipeId != nil {
            if let firstItem = items.first, let recipeName = firstItem.recipeName {
                sections.append(RecipeSection(
                    id: recipeId!,
                    recipeName: recipeName,
                    items: items,
                    isExpanded: expandedSections.contains(recipeId!)
                ))
            }
        }
        
        // Add "Other Items" section for items without recipe
        if let otherItems = grouped[nil], !otherItems.isEmpty {
            sections.append(RecipeSection(
                id: UUID(),
                recipeName: "Other Items",
                items: otherItems,
                isExpanded: expandedSections.contains(UUID())
            ))
        }
        
        return sections.sorted { $0.recipeName < $1.recipeName }
    }
    
    // Consolidated view - combine same ingredients across recipes
    private var consolidatedItems: [ConsolidatedItem] {
        var consolidation: [String: ConsolidatedItem] = [:]
        
        for item in viewModel.groceryList {
            let key = "\(item.name.lowercased())|\(item.unit)"
            
            if var existing = consolidation[key] {
                existing.totalQuantity += item.quantity
                if let recipeName = item.recipeName {
                    existing.recipes.append(recipeName)
                }
                consolidation[key] = existing
            } else {
                var recipes: [String] = []
                if let recipeName = item.recipeName {
                    recipes = [recipeName]
                }
                consolidation[key] = ConsolidatedItem(
                    id: UUID(),
                    name: item.name,
                    totalQuantity: item.quantity,
                    unit: item.unit,
                    recipes: recipes
                )
            }
        }
        
        return consolidation.values.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.groceryList.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Your Grocery List is Empty")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Add items from recipes you want to make")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                            selectedTab = 3  // Switch to Cookbook tab (index 3)
                        }) {
                            Text("Browse Recipes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.darkYellow)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    Text("By Recipe").tag(ViewMode.byRecipe)
                    Text("Consolidated").tag(ViewMode.consolidated)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if viewMode == .byRecipe {
                    recipeBasedList
                } else {
                    consolidatedList
                }
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.groceryList.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear All", role: .destructive) {
                            viewModel.clearGroceryList()
                            checkedItems.removeAll()
                        }
                        
                        Button("Expand All") {
                            expandAllSections()
                        }
                        
                        Button("Collapse All") {
                            collapseAllSections()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.appRed)
                    }
                }
            }
        }
        .alert("Item Added to Pantry", isPresented: .constant(alertMessage != nil)) {
            Button("OK") {
                alertMessage = nil
            }
        } message: {
            if let message = alertMessage {
                Text(message)
            }
        }
    }
    
    // MARK: - Recipe-Based List
    private var recipeBasedList: some View {
        List {
            ForEach(recipeSections) { section in
                Section {
                    if section.isExpanded {
                        ForEach(section.items) { item in
                            GroceryItemRow(
                                item: item,
                                isChecked: checkedItems.contains(item.id),
                                onCheck: { toggleItem(item) }
                            )
                        }
                        .onDelete { indexSet in
                            deleteItems(in: section, at: indexSet)
                        }
                    }
                } header: {
                    RecipeSectionHeader(
                        recipeName: section.recipeName,
                        itemCount: section.items.count,
                        isExpanded: section.isExpanded,
                        onToggle: { toggleSection(section.id) },
                        onAddAll: { addAllToCart(section) }
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Consolidated List
    private var consolidatedList: some View {
        List {
            ForEach(consolidatedItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Checkbox
                        Button(action: { toggleConsolidatedItem(item) }) {
                            Image(systemName: checkedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(checkedItems.contains(item.id) ? .green : .appGreen)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Item name
                        Text(item.name)
                            .font(.headline)
                            .strikethrough(checkedItems.contains(item.id))
                        
                        Spacer()
                        
                        // Total quantity
                        Text("\(String(format: "%.1f", item.totalQuantity)) \(item.unit)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.appYellow.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Recipe badges
                    if !item.recipes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(Set(item.recipes)).sorted(), id: \.self) { recipe in
                                    Text(recipe)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.appYellow.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.leading, 30)
                    }
                }
                .padding(.vertical, 4)
                .opacity(checkedItems.contains(item.id) ? 0.6 : 1.0)
            }
            .onDelete { indexSet in
                deleteConsolidatedItems(at: indexSet)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Helper Functions
    private func toggleSection(_ sectionId: UUID) {
        if expandedSections.contains(sectionId) {
            expandedSections.remove(sectionId)
        } else {
            expandedSections.insert(sectionId)
        }
    }
    
    private func expandAllSections() {
        for section in recipeSections {
            expandedSections.insert(section.id)
        }
    }
    
    private func collapseAllSections() {
        expandedSections.removeAll()
    }
    
    private func toggleItem(_ item: GroceryItem) {
        if checkedItems.contains(item.id) {
            checkedItems.remove(item.id)
        } else {
            checkedItems.insert(item.id)
            alertMessage = "Added \(item.name) to your pantry"
            
            // Auto-move to pantry after 2 seconds
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    if checkedItems.contains(item.id) {
                        viewModel.purchaseGroceryItem(item)
                        checkedItems.remove(item.id)
                    }
                }
            }
        }
    }
    
    private func toggleConsolidatedItem(_ item: ConsolidatedItem) {
        if checkedItems.contains(item.id) {
            checkedItems.remove(item.id)
        } else {
            checkedItems.insert(item.id)
            alertMessage = "Added \(item.name) to your pantry"
            
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    if checkedItems.contains(item.id) {
                        // Purchase all instances of this item
                        let itemsToPurchase = viewModel.groceryList.filter {
                            $0.name.lowercased() == item.name.lowercased() &&
                            $0.unit == item.unit
                        }
                        for groceryItem in itemsToPurchase {
                            viewModel.purchaseGroceryItem(groceryItem)
                        }
                        checkedItems.remove(item.id)
                    }
                }
            }
        }
    }
    
    private func addAllToCart(_ section: RecipeSection) {
        for item in section.items {
            if !checkedItems.contains(item.id) {
                checkedItems.insert(item.id)
            }
        }
        alertMessage = "Added all items from \(section.recipeName) to pantry"
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                for item in section.items {
                    if checkedItems.contains(item.id) {
                        viewModel.purchaseGroceryItem(item)
                        checkedItems.remove(item.id)
                    }
                }
            }
        }
    }
    
    private func deleteItems(in section: RecipeSection, at offsets: IndexSet) {
        let itemsToDelete = offsets.map { section.items[$0] }
        for item in itemsToDelete {
            checkedItems.remove(item.id)
            viewModel.groceryList.removeAll { $0.id == item.id }
        }
    }
    
    private func deleteConsolidatedItems(at offsets: IndexSet) {
        for index in offsets {
            let item = consolidatedItems[index]
            let itemsToDelete = viewModel.groceryList.filter {
                $0.name.lowercased() == item.name.lowercased() &&
                $0.unit == item.unit
            }
            for groceryItem in itemsToDelete {
                checkedItems.remove(groceryItem.id)
                viewModel.groceryList.removeAll { $0.id == groceryItem.id }
            }
        }
    }
}

// MARK: - Supporting Views
struct RecipeSectionHeader: View {
    let recipeName: String
    let itemCount: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddAll: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appRed)
                    
                    Text(recipeName)
                        .font(.headline)
                    
                    Text("(\(itemCount))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action: onAddAll) {
                Image(systemName: "cart.badge.plus")
                    .foregroundColor(.appRed)
            }
        }
        .padding(.vertical, 4)
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let isChecked: Bool
    let onCheck: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onCheck) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .appGreen)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(isChecked)
                
                Text("\(String(format: "%.1f", item.quantity)) \(item.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isChecked {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .opacity(isChecked ? 0.6 : 1.0)
        .padding(.vertical, 4)
    }
}

// MARK: - Models
enum ViewMode {
    case byRecipe
    case consolidated
}

struct RecipeSection: Identifiable {
    let id: UUID
    let recipeName: String
    let items: [GroceryItem]
    let isExpanded: Bool
}

struct ConsolidatedItem: Identifiable {
    let id: UUID
    let name: String
    var totalQuantity: Double
    let unit: String
    var recipes: [String]
}

