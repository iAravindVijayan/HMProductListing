//
//  ProductListViewModel.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Foundation

@Observable
@MainActor
final class ProductListViewModel {
    // MARK: - Properties

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var hasMorePages = true

    private var currentPage = 1
    private let pageSize = 20
    private var isLoadingMore = false

    let repository: ProductRepository

    // MARK: - Initialization

    init(repository: ProductRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func loadProducts() async {
        guard !isLoadingMore, !isLoading, hasMorePages else {
            return
        }

        isLoading = true
        isLoadingMore = true
        errorMessage = nil

        do {
            let newProducts = try await repository.fetchProducts(page: currentPage)

            // Only stop if API returns empty response
            if newProducts.isEmpty {
                hasMorePages = false
                isLoading = false
                isLoadingMore = false
                return
            }

            // Simply append all products from API
            products.append(contentsOf: newProducts)

            // Check if last page (fewer products than expected)
            if newProducts.count < pageSize {
                hasMorePages = false
            }

            currentPage += 1
            isLoading = false
            isLoadingMore = false

        } catch {
            isLoading = false
            isLoadingMore = false
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreProductsIfNeeded() async {
        await loadProducts()
    }

    func loadMoreProducts() async {
        errorMessage = nil
        isLoadingMore = false
        await loadProducts()
    }

    func refresh() async {
        products = []
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
        isLoadingMore = false

        await loadProducts()
    }
}
