//
//  CookbookView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

struct CookbookView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var selectedTab: CookbookTab = .favorites
    
    // All sample recipes
    private let allRecipes = Recipe.sampleRecipes
    
    // Filtered recipes based on search
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return allRecipes
        } else {
            return allRecipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Saved recipes
    private var savedRecipes: [Recipe] {
        filteredRecipes.filter { recipe in
            viewModel.savedRecipes.contains(where: { $0.id == recipe.id })
        }
    }
    
    // Unsaved recipes (sorted alphabetically)
    private var unsavedRecipes: [Recipe] {
        filteredRecipes.filter { recipe in
            !viewModel.savedRecipes.contains(where: { $0.id == recipe.id })
        }
        .sorted { $0.name < $1.name }
    }
    
    // Current recipes to display based on selected tab
    private var currentRecipes: [Recipe] {
        switch selectedTab {
        case .favorites:
            return savedRecipes
        case .all:
            return unsavedRecipes
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar (when active) - USING REUSABLE SEARCHBAR
                if showingSearch {
                    SearchBar(text: $searchText, placeholder: "Search recipes...")
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Custom Picker Tabs
                HStack(spacing: 0) {
                    TabButton(
                        title: "Favorites",
                        count: savedRecipes.count,
                        isSelected: selectedTab == .favorites,
                        action: { selectedTab = .favorites }
                    )
                    
                    TabButton(
                        title: "All Recipes",
                        count: unsavedRecipes.count,
                        isSelected: selectedTab == .all,
                        action: { selectedTab = .all }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Recipe Grid
                ScrollView {
                    if currentRecipes.isEmpty {
                        // Empty state based on tab
                        VStack(spacing: 20) {
                            Image(systemName: emptyStateIcon)
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text(emptyStateTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(emptyStateMessage)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(currentRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe).environmentObject(viewModel)) {
                                    CookbookRecipeCard(recipe: recipe, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cookbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Search button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring()) {
                            showingSearch.toggle()
                            if !showingSearch {
                                searchText = "" // Clear search when closing
                            }
                        }
                    } label: {
                        Image(systemName: showingSearch ? "xmark.circle.fill" : "magnifyingglass")
                            .foregroundColor(.appRed)
                    }
                }
            }
        }
    }
    
    // Empty state helpers
    private var emptyStateIcon: String {
        switch selectedTab {
        case .favorites:
            return "heart.slash"
        case .all:
            return "book.closed"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedTab {
        case .favorites:
            return "No Favorites Yet"
        case .all:
            return searchText.isEmpty ? "No Recipes Found" : "No Results"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case .favorites:
            return "Tap the heart icon on recipes you love to add them here"
        case .all:
            if searchText.isEmpty {
                return "Check back later for more recipes"
            } else {
                return "Try searching with a different keyword"
            }
        }
    }
}

// MARK: - Tab Enum
enum CookbookTab {
    case favorites
    case all
}

// MARK: - Custom Tab Button
struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Text("(\(count))")
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .appRed : .gray)
                }
                
                // Indicator bar
                Rectangle()
                    .fill(isSelected ? Color.appRed : Color.clear)
                    .frame(height: 2)
            }
            .foregroundColor(isSelected ? .appRed : .gray)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Cookbook Recipe Card
struct CookbookRecipeCard: View {
    let recipe: Recipe
    @ObservedObject var viewModel: KitchenViewModel

    private var isSaved: Bool {
        viewModel.savedRecipes.contains(where: { $0.id == recipe.id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image with heart
            ZStack(alignment: .topTrailing) {
                RecipeImageView(recipe: recipe)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button(action: {
                    if isSaved {
                        viewModel.unsaveRecipe(recipe)
                    } else {
                        viewModel.saveRecipe(recipe)
                    }
                }) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(isSaved ? .red : .white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                        .font(.title2.bold())
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Recipe name – wraps if needed
            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            // Difficulty & time
            HStack {
                Label(recipe.difficulty.rawValue, systemImage: recipe.difficulty.icon)
                    .font(.caption)
                Spacer()
                if recipe.totalTime > 0 {
                    Label(recipe.formattedTime, systemImage: "clock")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
        .frame(width: 150) // Fixed width
        .frame(maxHeight: .infinity, alignment: .top) // Expand & align top
    }
}

// MARK: - Recipe Image View
struct RecipeImageView: View {
    let recipe: Recipe
    
    var body: some View {
        if let imageURL = recipe.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.overlay(Image(systemName: "photo"))
                @unknown default:
                    EmptyView()
                }
            }
        } else if let imageName = recipe.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.gray.opacity(0.3)
                .overlay(Image(systemName: "photo"))
        }
    }
}

#Preview {
    CookbookView(viewModel: KitchenViewModel())
}
