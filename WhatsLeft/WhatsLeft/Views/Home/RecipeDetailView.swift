//
//  RecipeDetailView.swift
//  WhatsLeft
//
//  Created by Shi Lynn on 15/03/2026.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var kitchenVM: KitchenViewModel
    @State private var showingAddedAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let imageURL = recipe.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Color.gray
                                .frame(height: 200)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if let imageName = recipe.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                }

                // Title
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)

                // Difficulty & time
                HStack {
                    Label(recipe.difficulty.rawValue, systemImage: recipe.difficulty.icon)
                    Spacer()
                    if recipe.totalTime > 0 {
                        Label(recipe.formattedTime, systemImage: "clock")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

                // Ingredients
                Text("Ingredients")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                ForEach(recipe.ingredients) { ingredient in
                    HStack {
                        Text(ingredient.displayString)
                        Spacer()
                        // Check if ingredient is in pantry
                        if kitchenVM.availableIngredients.contains(where: { available in
                            available.lowercased().contains(ingredient.name.lowercased()) ||
                            ingredient.name.lowercased().contains(available.lowercased())
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }

                // Instructions
                if !recipe.instructions.isEmpty {
                    Text("Instructions")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        Text("\(index+1). \(step)")
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                    }
                } else {
                    Text("No instructions available.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // Buttons
                VStack(spacing: 12) {
                    Button("Add missing ingredients to grocery list") {
                        kitchenVM.addMissingIngredientsFromRecipe(recipe)
                        showingAddedAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(recipe.ingredients.isEmpty)

                    Button(recipe.isSaved ? "Remove from cookbook" : "Save to cookbook") {
                        if kitchenVM.savedRecipes.contains(where: { $0.id == recipe.id }) {
                            kitchenVM.unsaveRecipe(recipe)
                        } else {
                            kitchenVM.saveRecipe(recipe)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to grocery list", isPresented: $showingAddedAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
