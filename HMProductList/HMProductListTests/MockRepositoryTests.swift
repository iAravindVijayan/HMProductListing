//
//  MockRepositoryTests.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Testing
import Foundation
@testable import HMProductList

struct MockRepositoryTests {
    
    @Test("Mock repository generates 100 products by default")
    func mockRepositoryGeneratesProducts() {
        let repo = MockProductRepository()
        
        #expect(repo.mockProducts.count == 100)
    }
    
    @Test("Mock repository returns first page")
    func mockRepositoryFirstPage() async throws {
        let repo = await MockProductRepository.makeForTesting(delayDuration: 0)
        
        let products = try await repo.fetchProducts(page: 1)
        
        #expect(products.count == 20)
        #expect(products.first?.id == "1")
        #expect(products.last?.id == "20")
    }
    
    @Test("Mock repository returns second page")
    func mockRepositorySecondPage() async throws {
        let repo = await MockProductRepository.makeForTesting(delayDuration: 0)
        
        let products = try await repo.fetchProducts(page: 2)
        
        #expect(products.count == 20)
        #expect(products.first?.id == "21")
        #expect(products.last?.id == "40")
    }
    
    @Test("Mock repository returns empty beyond last page")
    func mockRepositoryBeyondLastPage() async throws {
        let repo = await MockProductRepository.makeForTesting(delayDuration: 0)
        
        let products = try await repo.fetchProducts(page: 10)
        
        #expect(products.isEmpty)
    }
    
    @Test("Mock repository throws error when configured")
    func mockRepositoryThrowsError() async {
        let repo = await MockProductRepository.makeFailing()
        
        do {
            _ = try await repo.fetchProducts(page: 1)
            Issue.record("Should have thrown error")
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == "MockProductRepository")
            #expect(nsError.code == -1)
        }
    }
    
    @Test("Empty mock repository returns empty results")
    func emptyMockRepository() async throws {
        let repo = await MockProductRepository.makeEmpty()
        
        let products = try await repo.fetchProducts(page: 1)
        
        #expect(products.isEmpty)
    }
    
    @Test("Mock repository products have unique IDs")
    func mockRepositoryUniqueIDs() {
        let repo = MockProductRepository.makeForTesting(delayDuration: 0)
        
        let ids = Set(repo.mockProducts.map { $0.id })
        
        #expect(ids.count == repo.mockProducts.count)
    }
    
    @Test("Mock repository products have variety")
    func mockRepositoryVariety() {
        let repo = MockProductRepository.makeForTesting(delayDuration: 0)
        
        let brands = Set(repo.mockProducts.compactMap { $0.brandName })
        let titles = Set(repo.mockProducts.map { $0.title })
        
        #expect(brands.count > 1)
        #expect(titles.count > 1)
    }
}
