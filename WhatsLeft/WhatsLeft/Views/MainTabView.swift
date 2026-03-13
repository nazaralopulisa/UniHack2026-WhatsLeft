//
//  MainTabView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Recipes Tab
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Recipes", systemImage: "fork.knife")
            }
            .tag(0)
            
            // Ingredients Tab
            NavigationStack {
                IngredientsView()
            }
            .tabItem {
                Label("Pantry", systemImage: "basket")
            }
            .tag(1)
            
            // Cookbook Tab
            NavigationStack {
                CookbookView()
            }
            .tabItem {
                Label("Cookbook", systemImage: "book")
            }
            .tag(2)
            
            // Grocery List Tab
            NavigationStack {
                GroceryListView()
            }
            .tabItem {
                Label("Grocery", systemImage: "cart")
            }
            .tag(3)
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
}
