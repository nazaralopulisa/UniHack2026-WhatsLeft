//
//  IngredientsView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct IngredientsView: View {
    var body: some View {
        VStack {
            Text("My Pantry")
                .font(.largeTitle)
                .bold()
            
            // Search bar placeholder
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text("Search ingredients...")
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            // Ingredients list placeholder
            List {
                ForEach(["Salt", "Pepper", "Olive Oil", "Flour", "Eggs"], id: \.self) { ingredient in
                    HStack {
                        Text(ingredient)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Pantry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Edit ingredients
                }
            }
        }
    }
}
