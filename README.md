# 🍅 WhatsLeft

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

WhatsLeft helps university students (and anyone with a busy schedule!) solve the daily "what's for dinner?" struggle. Simply input the ingredients you have on hand, and our app suggests recipes from easy to hard that you can actually make. Save your favorites to a personal cookbook, generate smart grocery lists for ingredients you need, and find the nearest stores to grab them. No more buying a whole new set of ingredients for every recipe!

## Features

- **AI-Powered Ingredient Scanning** – Take a photo of your ingredients and our custom-trained ML model identifies them
- **Smart Recipe Suggestions** – Get recipe recommendations based on what's in your pantry
- **Personal Cookbook** – Save your favorite recipes for quick access
- **Intelligent Grocery Lists** – Auto-generate shopping lists from recipes, with smart consolidation of duplicate ingredients
- **Search & Filter** – Find recipes by difficulty level or search by name

## Requirements

- **iOS**: 16.0 or later
- **Device**: iPhone (optimized for all models)
- **Internet**: Required for fetching new recipes from API
- **Storage**: ~50MB free space

## Installation

```bash
# Clone the repository
git clone https://github.com/nazaralopulisa/UniHack2026-WhatsLeft.git

# Open in Xcode
cd UniHack2026-WhatsLeft
open WhatsLeft.xcodeproj

# Select your target device/simulator and press Cmd+R to run
```

## Built With

- **SwiftUI** – Modern declarative UI framework
- **Core ML & Vision** – On-device machine learning for ingredient recognition
- **TheMealDB API** – Recipe database integration
- **MVVM Architecture** – Clean separation of concerns
- **Combine Framework** – Reactive state management

## Project Structure

```
WhatsLeft/
├── App/               # App entry point
├── Models/            # Data models (Ingredient, Recipe, etc.)
├── ViewModels/        # Business logic (KitchenViewModel)
├── Views/             # All UI components
│   ├── Components/    # Reusable UI elements
│   ├── Home/          # Recipe suggestions
│   ├── Pantry/        # Ingredient management
│   ├── Cookbook/      # Saved recipes
│   └── Grocery/       # Shopping lists
└── Assets/            # Images and app icons
```

## How It Works

1. **Add Ingredients** – Scan with camera or add manually
2. **Get Suggestions** – App shows recipes you can make
3. **Save Favorites** – Build your personal cookbook
4. **Shop Smart** – Generate consolidated grocery lists

## Machine Learning

We trained a custom Core ML model using the **GroceryStoreDataset** (5,125 supermarket images across 81 categories). The model achieves **76% accuracy** in recognizing common ingredients like fruits, vegetables, and packaged items – all running **entirely on-device** for privacy.

## Team

- **Nazara Lopulisa** – iOS Developer & ML Engineer
- **Akyla Mounira Irwan** – UI/UX Designer
- **Shi Lynn** – Backend & API Integration
- **Christy Lee** - Design & Video Pitch

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [TheMealDB](https://www.themealdb.com) for the amazing recipe API
- [GroceryStoreDataset](https://github.com/DaEfremov/GroceryStoreDataset) for training data
- UniHack2026 organizers and mentors
