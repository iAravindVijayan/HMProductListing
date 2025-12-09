//
//  MockProductRepository.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//


import Foundation
import SwiftUI

// MARK: - Mock Product Repository
final class MockProductRepository: ProductRepository {

    // MARK: - Properties

    var shouldFail = false
    var mockProducts: [Product] = []
    var delayDuration: UInt64 = 500_000_000 // 0.5 seconds

    // MARK: - Initialization

    init() {
        setupMockData()
    }

    // MARK: - Public Methods

    func fetchProducts(page: Int) async throws -> [Product] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: delayDuration)

        if shouldFail {
            throw NSError(
                domain: "MockProductRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Mock network error"]
            )
        }

        // Simulate pagination by returning different products for each page
        let productsPerPage = 20
        let startIndex = (page - 1) * productsPerPage
        let endIndex = min(startIndex + productsPerPage, mockProducts.count)

        guard startIndex < mockProducts.count else {
            return [] // No more products
        }

        return Array(mockProducts[startIndex..<endIndex])
    }

    func loadImage(from url: String) async -> Image? {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Return SF Symbol based on URL hash for variety
        let symbols = [
            "tshirt.fill",
            "figure.dress.line.vertical.figure",
            "backpack.fill",
            "shoe.fill",
            "eyeglasses",
            "handbag.fill"
        ]

        let index = abs(url.hashValue) % symbols.count
        return Image(systemName: symbols[index])
    }

    // MARK: - Helper Methods

    /// Configure mock repository for testing scenarios
    func configure(shouldFail: Bool = false, delayDuration: UInt64 = 500_000_000) {
        self.shouldFail = shouldFail
        self.delayDuration = delayDuration
    }

    /// Add custom mock products
    func setMockProducts(_ products: [Product]) {
        self.mockProducts = products
    }

    // MARK: - Private Methods

    private func setupMockData() {
        mockProducts = generateMockProducts(count: 100)
    }

    private func generateMockProducts(count: Int) -> [Product] {
        let brands = ["H&M", "ARKET", "COS", "& Other Stories", "Monki", "Weekday"]
        let collections = ["Essentials", "Divided", "Premium", "Studio", "Denim", nil]
        let styles = [
            "Slim Fit Jeans",
            "Regular Fit Jeans",
            "Wide Leg Jeans",
            "Skinny Jeans",
            "Relaxed Fit Jeans",
            "Bootcut Jeans",
            "Flared Jeans",
            "Straight Jeans",
            "Mom Jeans",
            "Baggy Jeans"
        ]

        return (1...count).map { index in
            let brandIndex = index % brands.count
            let styleIndex = index % styles.count
            let collectionIndex = index % collections.count
            let price = Double.random(in: 199...599)

            return Product(
                id: "\(index)",
                title: styles[styleIndex],
                price: String(format: "%.0f kr", price),
                imageURL: "https://image.hm.com/assets/hm/mock/product\(index).jpg",
                brandName: brands[brandIndex],
                collectionName: collections[collectionIndex]
            )
        }
    }
}

// MARK: - Mock Factory (for Testing)
extension MockProductRepository {

    /// Create mock repository with custom configuration
    static func makeForTesting(
        shouldFail: Bool = false,
        productCount: Int = 100,
        delayDuration: UInt64 = 0 // No delay for unit tests
    ) -> MockProductRepository {
        let repo = MockProductRepository()
        repo.shouldFail = shouldFail
        repo.delayDuration = delayDuration
        repo.mockProducts = repo.generateMockProducts(count: productCount)
        return repo
    }

    /// Create mock repository that returns empty results
    static func makeEmpty() -> MockProductRepository {
        let repo = MockProductRepository()
        repo.mockProducts = []
        repo.delayDuration = 0
        return repo
    }

    /// Create mock repository that always fails
    static func makeFailing() -> MockProductRepository {
        let repo = MockProductRepository()
        repo.shouldFail = true
        repo.delayDuration = 0
        return repo
    }
}
