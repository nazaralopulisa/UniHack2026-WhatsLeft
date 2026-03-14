//
//  CookbookView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct CookbookView: View {
    @ObservedObject var viewModel: KitchenViewModel

    // All sample recipes
    private let allRecipes = Recipe.sampleRecipes

    // Saved recipes appear first, then unsaved alphabetically
    private var sortedRecipes: [Recipe] {
        allRecipes.sorted { first, second in
            let firstSaved = viewModel.savedRecipes.contains(where: { $0.id == first.id })
            let secondSaved = viewModel.savedRecipes.contains(where: { $0.id == second.id })

            if firstSaved && !secondSaved { return true }
            if !firstSaved && secondSaved { return false }
            return first.name < second.name
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(sortedRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe).environmentObject(viewModel)) {
                            CookbookRecipeCard(recipe: recipe, viewModel: viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF7D0").ignoresSafeArea())
            .navigationTitle("Cookbook")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CookbookRecipeCard: View {
    let recipe: Recipe
    @ObservedObject var viewModel: KitchenViewModel

    private var isSaved: Bool {
        viewModel.savedRecipes.contains(where: { $0.id == recipe.id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                // Image using helper
                RecipeImageView(recipe: recipe)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // Heart button
                Button(action: {
                    if isSaved {
                        viewModel.unsaveRecipe(recipe)
                    } else {
                        viewModel.saveRecipe(recipe)
                    }
                }) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(isSaved ? .red : .white)
                        .padding(2)
                        .font(.title2.bold())
                }
                .padding(8)
                .buttonStyle(PlainButtonStyle())
            }

            Text(recipe.name)
                .font(.headline)
                .lineLimit(1)

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

// Helper view for recipe image
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

