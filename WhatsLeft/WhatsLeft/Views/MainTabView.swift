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
    
    let units = ["pieces", "grams", "kg", "cups", "tbsp", "tsp", "ml", "liters"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView
            TabView(selection: $selectedTab) {
                // Recipes Tab
                NavigationStack {
                    HomeView()
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
                    CookbookView()
                }
                .tabItem {
                    Label("Cookbook", systemImage: "book")
                }
                .tag(3)
                
                // Grocery Tab
                NavigationStack {
                    GroceryListView()
                }
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }
                .tag(4)
            }
            .tint(.orange)
            
            // Center Scan Button (floating above tab bar)
            Button {
                showingScanner = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 4)
                    
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        // Camera Scanner Sheet
        .sheet(isPresented: $showingScanner) {
            FoodCameraView(
                scannedIngredient: $scannedIngredient,
                isScanning: $showingScanner
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
                onSave: {
                    if let quantityValue = Double(quantity), !scannedIngredient.isEmpty {
                        let newIngredient = Ingredient(
                            name: scannedIngredient,
                            quantity: quantityValue,
                            unit: selectedUnit,
                            inStock: true,
                            category: .other
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
