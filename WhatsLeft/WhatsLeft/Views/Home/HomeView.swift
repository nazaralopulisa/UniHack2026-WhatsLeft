//
//  HomeView.swift
//  WhatsLeft
//
//  Created by Nazara on 14/03/26.
//

import SwiftUI

enum DifficultyTab: String, CaseIterable {
    case all = "All"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct HomeView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var selectedTab: DifficultyTab = .all

    // Counts for each difficulty
    private var easyCount: Int {
        viewModel.suggestedRecipes.filter { $0.difficulty == .easy }.count
    }
    private var mediumCount: Int {
        viewModel.suggestedRecipes.filter { $0.difficulty == .medium }.count
    }
    private var hardCount: Int {
        viewModel.suggestedRecipes.filter { $0.difficulty == .hard }.count
    }

    // Filtered recipes based on selected tab
    var filteredRecipes: [Recipe] {
        switch selectedTab {
        case .all:
            return viewModel.suggestedRecipes
        case .easy:
            return viewModel.suggestedRecipes.filter { $0.difficulty == .easy }
        case .medium:
            return viewModel.suggestedRecipes.filter { $0.difficulty == .medium }
        case .hard:
            return viewModel.suggestedRecipes.filter { $0.difficulty == .hard }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Difficulty tabs
                HStack(spacing: 0) {
                    TabButton(
                        title: DifficultyTab.all.rawValue,
                        count: viewModel.suggestedRecipes.count,
                        isSelected: selectedTab == .all,
                        action: { selectedTab = .all }
                    )
                    TabButton(
                        title: DifficultyTab.easy.rawValue,
                        count: easyCount,
                        isSelected: selectedTab == .easy,
                        action: { selectedTab = .easy }
                    )
                    TabButton(
                        title: DifficultyTab.medium.rawValue,
                        count: mediumCount,
                        isSelected: selectedTab == .medium,
                        action: { selectedTab = .medium }
                    )
                    TabButton(
                        title: DifficultyTab.hard.rawValue,
                        count: hardCount,
                        isSelected: selectedTab == .hard,
                        action: { selectedTab = .hard }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)

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
                                NavigationLink(destination: RecipeDetailView(recipe: recipe).environmentObject(viewModel)) {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
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

// MARK: - Tab Button
struct RecipieTabButton: View {
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

// MARK: - Recipe Card 
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let imageURL = recipe.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 150, height: 150)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if let imageName = recipe.imageName {
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
            }

            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

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
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
