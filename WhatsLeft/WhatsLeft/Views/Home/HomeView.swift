//
//  HomeView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var selectedDifficulty: Difficulty? = nil
    
    // Filter recipes based on selected difficulty
    var filteredRecipes: [Recipe] {
            guard let selected = selectedDifficulty else {
                return viewModel.suggestedRecipes // Use viewModel
            }
            return viewModel.suggestedRecipes.filter { $0.difficulty == selected }
        }
    
    var body: some View {
        NavigationView {
            VStack {
                // Difficulty filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // "All" chip
                        Chip(title: "All", isSelected: selectedDifficulty == nil) {
                            selectedDifficulty = nil
                        }
                        
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Chip(
                                title: difficulty.rawValue,
                                color: difficulty.color,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Main content area
                if viewModel.isLoadingRecipes && viewModel.suggestedRecipes.isEmpty {
                    ProgressView("Finding recipes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.recipeError {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Couldn't load recipes")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredRecipes.isEmpty {
                    VStack {
                        Image(systemName: "frying.pan")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No recipes found")
                            .font(.title2)
                            .bold()
                        Text("Try adding more ingredients to your pantry")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle()) // Prevents the card from looking like a button
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.fetchRecipeSuggestions()
                    }
                }
            }
            .navigationTitle("WhatsLeft")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Chip View (replaces your DifficultyChip)
struct Chip: View {
    let title: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.2))
                .foregroundColor(isSelected ? .white : color)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1)
                )
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            // Image (remote or local)
            if let imageURL = recipe.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(Image(systemName: "photo"))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 150, height: 150)
            } else if let imageName = recipe.imageName {
                // Local asset
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(Image(systemName: "photo"))
            }
            
            // Recipe name
            Text(recipe.name)
                .font(.headline)
                .lineLimit(1)
            
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
        .frame(width: 150)
    }
}
