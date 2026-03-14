//
//  WhatsLeftApp.swift
//  WhatsLeft
//
//  Created by Nazara  on 14/03/26.
//

import SwiftUI

@main
struct WhatsLeftApp: App {
    @StateObject private var kitchenVM = KitchenViewModel()
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(kitchenVM)
        }
    }
}
