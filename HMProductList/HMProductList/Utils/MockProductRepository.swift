//
//  MockProductRepository.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//


import Foundation
import SwiftUI
import NetworkEngine

final class MockProductRepository: ProductRepository {
    var shouldFail = false
    var mockProducts: [Product] = []
    var mockPagination: Pagination?
    
    init() {
        // Default mock data
        mockProducts = [
            Product(
                id: "1",
                title: "Slim Fit Jeans",
                price: "€ 34.99",
                imageURL: "https://image.hm.com/test1.jpg",
                brandName: "H&M",
                collectionName: "Divided"
            ),
            Product(
                id: "2",
                title: "Regular Fit Jeans",
                price: "€ 39.99",
                imageURL: "https://image.hm.com/test2.jpg",
                brandName: "H&M",
                collectionName: "Essentials"
            )
        ]
        
        mockPagination = Pagination(
            currentPage: 1,
            totalPages: 5,
            totalResults: 50
        )
    }
    
    func searchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: Pagination) {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        if shouldFail {
            throw RepositoryError.networkError(NetworkError.invalidResponse)
        }
        
        let pagination = mockPagination ?? Pagination(currentPage: page, totalPages: 1, totalResults: mockProducts.count)
        return (mockProducts, pagination)
    }
    
    func loadImage(from url: String) async -> Image? {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Return a simple placeholder using SF Symbols
        return Image(systemName: "photo.fill")
    }
}
