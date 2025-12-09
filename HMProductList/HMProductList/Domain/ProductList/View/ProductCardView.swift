//
//  ProductCardView.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//


import SwiftUI
import Localisation

struct ProductCardView: View {
    let product: Product
    let repository: ProductRepository
    
    @State private var image: Image?
    @State private var isLoading = true
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack {
                Color(uiColor: .systemGray6)
                
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel(product.accessibilityImageLabel)
                } else if isLoading {
                    ProgressView()
                        .accessibilityLabel(UIStrings.loadingImage.localized)
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(UIStrings.imageUnavailable.localized)
                }
            }
            .frame(height: imageHeight)
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                // Brand / Collection / Title
                Text(product.displayTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Price
                Text(product.price)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(product.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(UIStrings.cardHint.localized)
        .task {
            await loadImage()
        }
    }
    
    // Adaptive image height based on Dynamic Type
    private var imageHeight: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return 150
        }
        return 200
    }
    
    private func loadImage() async {
        isLoading = true
        image = await repository.loadImage(from: product.imageURL)
        isLoading = false
    }
}

// MARK: - Product Accessibility Extensions
extension Product {
    var accessibilityLabel: String {
        var label = ""
        
        if let brand = brandName {
            label += brand + ", "
        }
        if let collection = collectionName {
            label += collection + ", "
        }
        label += title + ", "
        label += price
        
        return label
    }
    
    var accessibilityImageLabel: String {
        return UIStrings.productImage.localized + " " + title
    }
}

// MARK: - Dynamic Type Size Extension
extension DynamicTypeSize {
    var isAccessibilitySize: Bool {
        return self >= .accessibility1
    }
}
