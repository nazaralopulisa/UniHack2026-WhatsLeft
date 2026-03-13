//
//  CookbookView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct CookbookView: View {
    var body: some View {
        VStack {
            Text("My Cookbook")
                .font(.largeTitle)
                .bold()
            
            if true {
                ContentUnavailableView(
                    "No Saved Recipes",
                    systemImage: "book.closed",
                    description: Text("Recipes you heart will appear here")
                )
            } else {
                
                Text("Saved recipes appear here")
            }
        }
        .navigationTitle("Cookbook")
        .navigationBarTitleDisplayMode(.inline)
    }
}
