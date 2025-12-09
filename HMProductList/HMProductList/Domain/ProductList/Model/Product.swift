//
//  Product.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-08.
//


import Foundation

struct Product: Identifiable, Equatable {
    let id: String
    let title: String
    let price: String
    let imageURL: String
    let brandName: String?
    let collectionName: String?
    
    var displayTitle: String {
        if let brand = brandName, let collection = collectionName {
            return "\(brand) / \(collection)\n\(title)"
        } else if let brand = brandName {
            return "\(brand)\n\(title)"
        }
        return title
    }
}

// MARK: - API Response Models
struct ProductSearchResponse: Codable {
    let searchHits: SearchHits
}

struct SearchHits: Codable {
    let productList: [ProductDTO]
}

// MARK: - Product DTO
struct ProductDTO: Codable {
    let id: String
    let productName: String
    let brandName: String
    let prices: [PriceInfo]
    let productImage: String
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case productName
        case brandName
        case prices
        case productImage
        case url
    }
}

struct PriceInfo: Codable {
    let price: Double
    let formattedPrice: String
}

// MARK: - Domain Conversion
extension ProductDTO {
    func toDomain() -> Product {
        let priceValue = prices.first?.price ?? 0.0
        let formattedPrice = prices.first?.formattedPrice ?? String(format: "%.2f kr", priceValue)

        return Product(
            id: id,
            title: productName,
            price: formattedPrice,
            imageURL: productImage,
            brandName: brandName,
            collectionName: nil
        )
    }
}
