//
//  HMProductListApp.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-08.
//

import SwiftUI
import NetworkEngine
import CacheManager

@main
struct HMProductListApp: App {
    var body: some Scene {
        WindowGroup {
            ProductListView(
                viewModel: ProductListViewModel(
                    repository: DefaultProductRepository(
                        networkService: DefaultNetworkService(),
                        imageCache: ImageCacheManager.shared
                    )
                )
            )
        }
    }
}
