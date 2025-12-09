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
struct ProductSearchResponse: Decodable {
    let productList: [ProductDTO]
    let pagination: Pagination
    
    enum CodingKeys: String, CodingKey {
        case productList, pagination
    }
}

struct ProductDTO: Decodable {
    let articleCode: String
    let title: String
    let price: String
    let image: String
    let brandName: String?
    let collectionName: String?
    
    enum CodingKeys: String, CodingKey {
        case articleCode, title, price, image, brandName, collectionName
    }
    
    func toDomain() -> Product {
        return Product(
            id: articleCode,
            title: title,
            price: price,
            imageURL: image,
            brandName: brandName,
            collectionName: collectionName
        )
    }
}

struct Pagination: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    
    var hasMore: Bool {
        return currentPage < totalPages
    }
}
