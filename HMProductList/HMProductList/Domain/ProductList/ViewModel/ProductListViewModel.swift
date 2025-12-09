//
//  ProductListViewModel.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Foundation
import Observation

@Observable
@MainActor
final class ProductListViewModel {
    // MARK: - Published Properties
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var hasMorePages = true

    let repository: ProductRepository
    private var currentPage = 1

    // Prevent duplicate pagination requests
    private var isPaginationInProgress = false

    // MARK: - Initialization
    init(repository: ProductRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods
    /// Load initial products
    func loadProducts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let newProducts = try await repository.fetchProducts(page: currentPage)

            if newProducts.isEmpty {
                hasMorePages = false
            } else {
                products.append(contentsOf: newProducts)
                currentPage += 1
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Load next page (pagination)
    func loadMoreIfNeeded(currentProduct product: Product) async {
        // Trigger pagination when user reaches near the end
        guard let lastProduct = products.last,
              lastProduct.id == product.id,
              hasMorePages,
              !isPaginationInProgress,
              !isLoading else {
            return
        }

        await loadNextPage()
    }

    /// Refresh (pull to refresh)
    func refresh() async {
        products = []
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
        await loadProducts()
    }

    func loadNextPage() async {
        isPaginationInProgress = true

        do {
            let newProducts = try await repository.fetchProducts(page: currentPage)

            if newProducts.isEmpty {
                hasMorePages = false
            } else {
                products.append(contentsOf: newProducts)
                currentPage += 1
            }

            print("Loaded page \(currentPage - 1): \(newProducts.count) more products")
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading more products: \(error)")
        }

        isPaginationInProgress = false
    }
}
