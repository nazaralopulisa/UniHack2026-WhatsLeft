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
    @State private var tomatoScale: CGFloat = 4.0 // Start super zoomed in
    @State private var tomatoOffset: CGFloat = 0
    @State private var tomatoRotation: Double = 0
    @State private var splatEffect = false
    @State private var showTitleTomato = false
    @State private var buttonOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    
    // Bigger final tomato size
    private let finalTomatoSize: CGFloat = 300 // Increased from 300 to 400
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "FFF7D0")
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    Spacer()
                    
                    // Tomato Animation
                    ZStack {
                        // Empty tomato (zoomed in initially)
                        Image("tomatosymbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: finalTomatoSize, height: finalTomatoSize)
                            .scaleEffect(tomatoScale)
                            .offset(y: tomatoOffset)
                            .rotationEffect(.degrees(tomatoRotation))
                            .opacity(showTitleTomato ? 0 : 1)
                        
                        // Tomato with text (appears after splat) - NOW BIGGER
                        Image("tomatotext")
                            .resizable()
                            .scaledToFit()
                            .frame(width: finalTomatoSize, height: finalTomatoSize)
                            .scaleEffect(splatEffect ? 1.0 : 0.8)
                            .opacity(showTitleTomato ? 1 : 0)
                    }
                    
                    // Tagline
                    Text("Make the most out of WhatsLeft.")
                        .font(.title3) // Slightly larger font
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                        .opacity(taglineOpacity)
                    
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
                    .opacity(buttonOpacity)
                    .padding(.bottom, 50)
                    
                    NavigationLink(destination: MainTabView(), isActive: $isActive) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .onAppear {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        // Phase 1: Zoomed in at start (already set)
        
        // Phase 2: Throw animation - zoom out quickly
        withAnimation(.easeOut(duration: 0.6)) {
            tomatoScale = 1.3 // Zoom out to slightly larger than final
            tomatoOffset = -40 // Move up slightly (throwing motion)
            tomatoRotation = 15 // Slight rotation during throw
        }
        
        // Phase 3: Splat effect - quick squash
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                tomatoOffset = 0 // Reset position
                tomatoRotation = 0 // Reset rotation
                tomatoScale = 0.95 // Squash down
            }
            
            // Phase 4: Reveal the title tomato with a pop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    showTitleTomato = true
                    splatEffect = true
                    tomatoScale = 0 // Hide empty tomato
                }
                
                // Phase 5: Bounce the title tomato
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
//                        splatEffect = false
//                    }
                }
                
                // Phase 6: Fade in tagline and button
                withAnimation(.easeIn(duration: 0.5)) {
                    taglineOpacity = 1.0
                }
                
                withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
//}

#Preview {
    LandingView()
}
