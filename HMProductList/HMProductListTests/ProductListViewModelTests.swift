//
//  HMProductListTests.swift
//  HMProductListTests
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Testing
import Foundation
@testable import HMProductList

@MainActor
struct ProductListViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with empty state")
    func viewModelInitialState() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        #expect(viewModel.products.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasMorePages == true)
    }
    
    // MARK: - Load Products Tests
    
    @Test("Load first page successfully")
    func loadFirstPage() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        
        #expect(viewModel.products.count == 20)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasMorePages == true)
    }
    
    @Test("Load multiple pages")
    func loadMultiplePages() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        await viewModel.loadProducts()
        await viewModel.loadProducts()
        
        #expect(viewModel.products.count == 60)
        #expect(viewModel.hasMorePages == true)
    }
    
    @Test("Detect last page with partial results")
    func detectLastPagePartial() async {
        let mockRepo = MockProductRepository.makeForTesting(
            productCount: 35,
            delayDuration: 0
        )
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts() // 20 products
        await viewModel.loadProducts() // 15 products
        
        #expect(viewModel.products.count == 35)
        #expect(viewModel.hasMorePages == false)
    }
    
    @Test("Handle empty response")
    func handleEmptyResponse() async {
        let mockRepo = MockProductRepository.makeEmpty()
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        
        #expect(viewModel.products.isEmpty)
        #expect(viewModel.hasMorePages == false)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Handle error response")
    func handleErrorResponse() async {
        let mockRepo = MockProductRepository.makeFailing()
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        
        #expect(viewModel.products.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Refresh Tests
    
    @Test("Refresh resets state and reloads")
    func refreshResetsState() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        #expect(viewModel.products.count == 20)
        
        await viewModel.refresh()
        
        #expect(viewModel.products.count == 20)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasMorePages == true)
    }
    
    @Test("Refresh recovers from error")
    func refreshRecoversFromError() async {
        let mockRepo = MockProductRepository.makeFailing()
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        #expect(viewModel.errorMessage != nil)
        
        mockRepo.shouldFail = false
        await viewModel.refresh()
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.products.count == 20)
    }
    
    // MARK: - Load More Tests
    
    @Test("Load more clears error")
    func loadMoreClearsError() async {
        let mockRepo = MockProductRepository.makeFailing()
        let viewModel = ProductListViewModel(repository: mockRepo)
        
        await viewModel.loadProducts()
        #expect(viewModel.errorMessage != nil)
        
        mockRepo.shouldFail = false
        await viewModel.loadMoreProducts()
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.products.count == 20)
    }
}

