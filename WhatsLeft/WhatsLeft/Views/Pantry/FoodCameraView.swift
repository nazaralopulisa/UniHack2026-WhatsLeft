//
//  FoodCameraView.swift
//  WhatsLeft
//
//  Created by YourName on 14/03/26.
//

import SwiftUI
import AVFoundation
import Vision

struct FoodCameraView: View {
    @Binding var scannedIngredient: String
    @Binding var isScanning: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var isTakingPhoto = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var recognizedFood = ""
    @State private var confidence: Float = 0.0
    @State private var showResult = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Confidence threshold - only show results above this
    private let confidenceThreshold: Float = 0.6
    
    var body: some View {
        NavigationStack {
            VStack {
                if isProcessing {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("Analyzing food...")
                            .font(.headline)
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else if showResult, let image = selectedImage {
                    // Show result with the captured image
                    VStack(spacing: 20) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(confidence > confidenceThreshold ? Color.green : Color.orange, lineWidth: 3)
                            )
                        
                        Text("I found:")
                            .font(.headline)
                        
                        Text(recognizedFood)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.orange)
                        
                        // Confidence meter
                        VStack(spacing: 5) {
                            HStack {
                                Text("Confidence:")
                                Spacer()
                                Text("\(Int(confidence * 100))%")
                                    .bold()
                                    .foregroundColor(confidence > confidenceThreshold ? .green : .orange)
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                    
                                    Rectangle()
                                        .frame(width: min(CGFloat(confidence) * geometry.size.width, geometry.size.width), height: 8)
                                        .foregroundColor(confidence > confidenceThreshold ? .green : .orange)
                                }
                                .cornerRadius(4)
                            }
                            .frame(height: 8)
                        }
                        .padding(.horizontal)
                        
                        if confidence < confidenceThreshold {
                            Text("I'm not very sure about this one. Want to try again?")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 20) {
                            Button("Try Again") {
                                selectedImage = nil
                                showResult = false
                                recognizedFood = ""
                                confidence = 0
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Use This") {
                                scannedIngredient = recognizedFood
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .disabled(confidence < confidenceThreshold) // Disable if low confidence
                        }
                        .padding()
                        
                        // Manual entry option
                        if confidence < confidenceThreshold {
                            Button("Type manually") {
                                // You could present a text field here
                                // For now, just dismiss and they can type
                                dismiss()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                } else {
                    // Camera preview or options
                    VStack(spacing: 30) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text("Take a photo of your ingredient")
                            .font(.headline)
                        
                        Text("Your custom FoodAI model will identify it")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 30) {
                            Button {
                                isTakingPhoto = true
                            } label: {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.largeTitle)
                                    Text("Take Photo")
                                }
                                .frame(width: 120, height: 120)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(20)
                            }
                            
                            Button {
                                showingImagePicker = true
                            } label: {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                    Text("Choose Photo")
                                }
                                .frame(width: 120, height: 120)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isTakingPhoto) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    isProcessing = true
                    recognizeFood(image: image)
                }
            }
        }
    }
    
    func recognizeFood(image: UIImage) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.errorMessage = "Could not process image"
                self.showError = true
            }
            return
        }
        
        // Load YOUR trained model (use the exact class name from Xcode)
        guard let model = try? VNCoreMLModel(for: GroceryPantryAI(configuration: MLModelConfiguration()).model) else {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.errorMessage = "Failed to load food recognition model"
                self.showError = true
            }
            return
        }
        
        // Create a Vision request
        let request = VNCoreMLRequest(model: model) { request, error in
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Recognition failed: \(error.localizedDescription)"
                    self.showError = true
                }
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.errorMessage = "No food detected"
                    self.showError = true
                }
                return
            }
            
            // Process the result
            let foodName = topResult.identifier
            let confidence = topResult.confidence
            
            print("Recognized: \(foodName) with confidence \(confidence)")
            
            // Clean up the food name (remove underscores, etc.)
            let cleanedName = self.cleanFoodName(foodName)
            
            DispatchQueue.main.async {
                self.recognizedFood = cleanedName
                self.confidence = Float(confidence)
                self.showResult = true
            }
        }
        
        // Set request properties
        request.imageCropAndScaleOption = .centerCrop
        
        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: self.getCGImageOrientation(from: image.imageOrientation))
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Failed to analyze image: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    func cleanFoodName(_ name: String) -> String {
        // Remove anything after a comma (e.g., "pizza, margherita" -> "pizza")
        var cleaned = name.components(separatedBy: ",").first ?? name
        
        // Remove numbers and special characters
        cleaned = cleaned.replacingOccurrences(of: "[0-9_]", with: "", options: .regularExpression)
        
        // Replace underscores with spaces
        cleaned = cleaned.replacingOccurrences(of: "_", with: " ")
        
        // Capitalize each word
        cleaned = cleaned.split(separator: " ").map { word in
            word.capitalized
        }.joined(separator: " ")
        
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    // Helper to convert UIImageOrientation to CGImagePropertyOrientation
    func getCGImageOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

// MARK: - Image Picker Component
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
