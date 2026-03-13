//
//  GroceryListView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct GroceryListView: View {
    var body: some View {
        VStack {
            Text("Grocery List")
                .font(.largeTitle)
                .bold()
            
            if true { 
                ContentUnavailableView(
                    "List is Empty",
                    systemImage: "cart",
                    description: Text("Add items from recipes you want to make")
                )
            } else {
                List {
                    // Items will go here
                }
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear") {
                    // Clear list
                }
            }
        }
    }
}
