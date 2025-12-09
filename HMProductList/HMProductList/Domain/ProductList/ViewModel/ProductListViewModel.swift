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
            print("Guard blocked: isLoadingMore=\(isLoadingMore), isLoading=\(isLoading), hasMorePages=\(hasMorePages)")
            return
        }

        print("Starting load for page \(currentPage)")
        isLoading = true
        isLoadingMore = true
        errorMessage = nil

        do {
            let newProducts = try await repository.fetchProducts(page: currentPage)
            print("Received \(newProducts.count) products from API for page \(currentPage)")

            // Only stop if API returns empty response
            if newProducts.isEmpty {
                print("Empty response - stopping pagination")
                hasMorePages = false
                isLoading = false
                isLoadingMore = false
                return
            }

            // Simply append all products from API
            products.append(contentsOf: newProducts)
            print("Total products displayed: \(products.count)")

            // Check if last page (fewer products than expected)
            if newProducts.count < pageSize {
                print("Received \(newProducts.count) < \(pageSize) - last page")
                hasMorePages = false
            }

            currentPage += 1
            isLoading = false
            isLoadingMore = false

        } catch {
            print("Error: \(error.localizedDescription)")
            isLoading = false
            isLoadingMore = false
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreProductsIfNeeded() async {
        print("loadMoreProductsIfNeeded called")
        await loadProducts()
    }

    func loadMoreProducts() async {
        print("loadMoreProducts (retry) called")
        errorMessage = nil
        isLoadingMore = false
        await loadProducts()
    }

    func refresh() async {
        print("Refresh called")
        products = []
        currentPage = 1
        hasMorePages = true
        errorMessage = nil
        isLoadingMore = false

        await loadProducts()
    }
}
