//
//  IntegrationTests.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Testing
import Foundation
@testable import HMProductList

@MainActor
struct IntegrationTests {

    @Test("ViewModel works with mock repository")
    func viewModelMockIntegration() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)

        await viewModel.loadProducts()

        #expect(viewModel.products.count == 20)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("ViewModel pagination works end-to-end")
    func viewModelPaginationEndToEnd() async {
        let mockRepo = MockProductRepository.makeForTesting(delayDuration: 0)
        let viewModel = ProductListViewModel(repository: mockRepo)

        await viewModel.loadProducts()
        await viewModel.loadProducts()
        await viewModel.loadProducts()

        #expect(viewModel.products.count == 60)
    }

    @Test("ViewModel error handling works end-to-end")
    func viewModelErrorHandlingEndToEnd() async {
        let mockRepo = MockProductRepository.makeFailing()
        let viewModel = ProductListViewModel(repository: mockRepo)

        await viewModel.loadProducts()

        #expect(viewModel.products.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
}
