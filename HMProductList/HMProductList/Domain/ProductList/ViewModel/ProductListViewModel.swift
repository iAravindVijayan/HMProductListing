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
    private var currentPage = 0
    private let searchQuery = "jeans"
    
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
        currentPage = 1
        
        do {
            let result = try await repository.searchProducts(query: searchQuery, page: currentPage)
            products = result.products
            hasMorePages = result.pagination.hasMore
            
            print("Loaded \(result.products.count) products (Page \(currentPage)/\(result.pagination.totalPages))")
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading products: \(error)")
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
        currentPage = 0
        hasMorePages = true
        await loadProducts()
    }
    
    // MARK: - Private Methods
    private func loadNextPage() async {
        isPaginationInProgress = true
        currentPage += 1
        
        do {
            let result = try await repository.searchProducts(query: searchQuery, page: currentPage)
            products.append(contentsOf: result.products)
            hasMorePages = result.pagination.hasMore
            
            print("Loaded page \(currentPage): \(result.products.count) more products")
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1 // Revert page increment on error
            print("Error loading more products: \(error)")
        }
        
        isPaginationInProgress = false
    }
}
