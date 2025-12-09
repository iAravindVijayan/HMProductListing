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
                        .aspectRatio(contentMode: .fill)
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
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(product.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(UIStrings.cardHint.localized)
        .task {
            await loadImage()
        }
    }
    
    // MARK: - Adaptive Image Height
    
    /// Image height that adapts to Dynamic Type size
    /// Smaller images for accessibility sizes to leave more room for text
    private var imageHeight: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small:
            return 180
        case .medium, .large:
            return 200
        case .xLarge, .xxLarge, .xxxLarge:
            return 220
        case .accessibility1, .accessibility2:
            return 150
        case .accessibility3, .accessibility4, .accessibility5:
            return 120
        @unknown default:
            return 200
        }
    }
    
    // MARK: - Image Loading
    
    private func loadImage() async {
        isLoading = true
        image = await repository.loadImage(from: product.imageURL)
        isLoading = false
    }
}

// MARK: - Product Accessibility Extensions

extension Product {
    /// Complete accessibility label combining all product information
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
    
    /// Accessibility label for product image
    var accessibilityImageLabel: String {
        return UIStrings.productImage.localized + " " + title
    }
}

// MARK: - Dynamic Type Size Extension

extension DynamicTypeSize {
    /// Whether this is an accessibility size (larger than standard sizes)
    var isAccessibilitySize: Bool {
        return self >= .accessibility1
    }
}
