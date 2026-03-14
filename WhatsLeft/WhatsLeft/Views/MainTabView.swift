//
//  MainTabView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject var kitchenVM = KitchenViewModel()
    
    // Scanner states
    @State private var showingScanner = false
    @State private var scannedIngredient = ""
    @State private var showingQuantitySheet = false
    @State private var quantity = ""
    @State private var selectedUnit = "pieces"
    @State private var selectedCategory: IngredientCategory = .other
    
    
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView
            TabView(selection: $selectedTab) {
                // Recipes Tab
                NavigationStack {
                    HomeView(viewModel: kitchenVM)
                }
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(0)
                
                // Pantry Tab
                NavigationStack {
                    IngredientsView(viewModel: kitchenVM)
                }
                .tabItem {
                    Label("Pantry", systemImage: "basket")
                }
                .tag(1)
                
                // Spacer for center button (invisible tab)
                Color.clear
                    .tabItem { EmptyView() }
                    .tag(2)
                
                // Cookbook Tab
                NavigationStack {
                    CookbookView(viewModel: kitchenVM)
                }
                .tabItem {
                    Label("Cookbook", systemImage: "book")
                }
                .tag(3)
                
                // Grocery Tab
                NavigationStack {
                    GroceryListView(viewModel: kitchenVM, selectedTab: $selectedTab)  // Pass the binding
                }
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }
                .tag(4)
            }
            .tint(.appGreen)
            
            // Center Scan Button (floating above tab bar)
            Button {
                showingScanner = true
            } label: {
                ZStack {
                    // Tomato image
                    Image("tomatosymbol")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .shadow(radius: 2)
                    
                    // Camera symbol overlay
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                        .foregroundColor(.appYellow)
                        .offset(y: 4)
                }
            }
            .offset(y: 8)

        }
        .ignoresSafeArea(.keyboard)
        // Camera Scanner Sheet
        .sheet(isPresented: $showingScanner) {
            FoodCameraView(
                scannedIngredient: $scannedIngredient,
                isScanning: $showingScanner,
                onManualEntry: { ingredientName in
                    // If ingredientName is provided, pre-fill it
                    if !ingredientName.isEmpty {
                        scannedIngredient = ingredientName
                    }
                    
                    // Show quantity sheet for manual entry
                    showingQuantitySheet = true
                }
            )
        }
        // Quantity Sheet (after scanning)
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
                category: $selectedCategory,
                onSave: {
                    if let quantityValue = Double(quantity), !scannedIngredient.isEmpty {
                        let newIngredient = Ingredient(
                            name: scannedIngredient,
                            quantity: quantityValue,
                            unit: selectedUnit,
                            inStock: true,
                            category: selectedCategory
                        )
                        kitchenVM.addIngredient(newIngredient)
                        
                        // Reset values
                        scannedIngredient = ""
                        quantity = ""
                        selectedUnit = "pieces"
                        
                        // Dismiss the sheet
                        showingQuantitySheet = false
                    }
                }
            )
        }
        .environmentObject(kitchenVM)
    }
}

#Preview {
    MainTabView()
}
