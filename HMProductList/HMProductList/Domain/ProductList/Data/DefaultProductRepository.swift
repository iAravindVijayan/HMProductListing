//
//  ProductRepositoryImpl.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-09.
//

import Foundation
import NetworkEngine
import CacheManager
import SwiftUI

final class DefaultProductRepository: ProductRepository {
    private let networkService: NetworkService
    private let imageCache: ImageCacheManager

    init(
        networkService: NetworkService,
        imageCache: ImageCacheManager
    ) {
        self.networkService = networkService
        self.imageCache = imageCache
    }

    func fetchProducts(page: Int) async throws -> [Product] {
        let endpoint = Endpoint.products(page: page)
        let response: ProductSearchResponse = try await networkService.request(endpoint)
        return response.searchHits.productList.map { $0.toDomain() }
    }

    func loadImage(from url: String) async -> Image? {
        await imageCache.loadImage(from: url)
    }
}
