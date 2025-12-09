//
//  ProductRepository.swift
//  HMProductList
//
//  Created by Aravind Vijayan on 2025-12-08.
//

import Foundation
import Localisation
import SwiftUI

// MARK: - Repository Protocol
protocol ProductRepository {
    func searchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: Pagination)
    func loadImage(from url: String) async -> Image?
}

// MARK: - Repository Errors
enum RepositoryError: LocalizedError {
    case networkError(Error)
    case decodingError
    case invalidURL
    case noData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return UIStrings.networkError.localized + ": \(error.localizedDescription)"
        case .decodingError:
            return UIStrings.decodingError.localized
        case .invalidURL:
            return UIStrings.invalidUrl.localized
        case .noData:
            return UIStrings.noDataError.localized
        }
    }
}
