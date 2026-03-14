//
//  GroceryListView.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

struct GroceryListView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var purchasingItems = Set<UUID>()
    @State private var alertMessage: String?

    var body: some View {
        VStack {
            Text("Grocery List")
                .padding()
                .font(.title)
                .bold()
            if viewModel.groceryList.isEmpty {
                ContentUnavailableView(
                    "List is Empty",
                    systemImage: "cart",
                    description: Text("Add items from recipes you want to make")
                )
            } else {
                List {
                    ForEach(viewModel.groceryList) { item in
                        HStack {
                            // Checkbox button
                            Button(action: {
                                guard !purchasingItems.contains(item.id) else { return }
                                purchasingItems.insert(item.id)
                                alertMessage = "Added \(item.displayString) to your pantry."

                                // Schedule removal after 2 seconds
                                Task {
                                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                                    await MainActor.run {
                                        viewModel.purchaseGroceryItem(item)
                                        purchasingItems.remove(item.id)
                                    }
                                }
                            }) {
                                Image(systemName: purchasingItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(purchasingItems.contains(item.id) ? .green : .blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(purchasingItems.contains(item.id))

                            // Item description
                            Text(item.displayString)
                        }
                    }
                    .onDelete { indexSet in
                        // Remove from purchasingItems if deleted manually
                        for index in indexSet {
                            let item = viewModel.groceryList[index]
                            purchasingItems.remove(item.id)
                        }
                        viewModel.removeFromGroceryList(at: indexSet)
                    }
                }
            }
        }
        .toolbar {
            if !viewModel.groceryList.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearGroceryList()
                        purchasingItems.removeAll()
                    }
                }
            }
        }
        .alert("Item Added", isPresented: .constant(alertMessage != nil)) {
            Button("OK") {
                alertMessage = nil
            }
        } message: {
            if let message = alertMessage {
                Text(message)
            }
        }
    }
}

#Preview {
    GroceryListView(viewModel: KitchenViewModel())
}
