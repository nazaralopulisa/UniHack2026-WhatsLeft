//
//  HomeView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Recipe Recommendations")
                .font(.largeTitle)
                .bold()
            
            // Difficulty filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    DifficultyChip(title: "Easy", color: .green)
                    DifficultyChip(title: "Medium", color: .orange)
                    DifficultyChip(title: "Hard", color: .red)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Placeholder recipe grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(0..<4) { _ in
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 150)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "photo")
                                                Text("Recipe Name")
                                                    .font(.caption)
                                            }
                                        )
                                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("WhatsLeft")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DifficultyChip: View {
    let title: String
        let color: Color
        
        var body: some View {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1)
                )
        }
}
