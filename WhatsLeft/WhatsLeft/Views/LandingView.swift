//
//  LandingView.swift
//  WhatsLeft
//
//  Created by Akyla Mounira Irwan on 15/03/2026.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LandingView: View {
    @State private var isActive = false
    @State private var xOffset: CGFloat = -400          // start far left
    @State private var firstImageVisible = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Color.clear.frame(height: 150)

                // Fading icon with side bounce
                ZStack {
                    // First image – bounces in from left
                    Image("tomatosymbol")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .offset(x: xOffset)
                        .opacity(firstImageVisible ? 1 : 0)

                    // Second image – centered, hidden initially
                    Image("tomatotext")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .opacity(firstImageVisible ? 0 : 1)
                }
                .onAppear {
                    // Bounce the first image into center (x = 0)
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.5)) {
                        xOffset = 0
                    }

                    // Wait for bounce to settle, then fade to second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            firstImageVisible = false
                        }
                    }
                }

                // Tagline
                Text("Make the most out of WhatsLeft.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)

                Spacer()

                // Get Started Button
                Button(action: { isActive = true }) {
                    Text("Get Cooking!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "639362"))
                        .cornerRadius(12)
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 50)

                NavigationLink(destination: MainTabView(), isActive: $isActive) {
                    EmptyView()
                }
                .hidden()
            }
            .background(Color(hex: "FFF7D0").ignoresSafeArea())
        }
    }
}

#Preview {
    LandingView()
}
