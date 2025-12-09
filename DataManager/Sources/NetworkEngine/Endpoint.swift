//
//  Endpoint.swift
//  DataManager
//
//  Created by Aravind Vijayan on 2025-12-08.
//

import Foundation

public struct Endpoint {
    public let path: String
    public let queryItems: [URLQueryItem]

    public var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.hm.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}

// MARK: - API Endpoints
public extension Endpoint {
    static func products(page: Int) -> Endpoint {
        Endpoint(
            path: "/search-services/v1/sv_se/search/resultpage",
            queryItems: [
                URLQueryItem(name: "query", value: "jeans"),
                URLQueryItem(name: "touchPoint", value: "ios"),
                URLQueryItem(name: "currentPage", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "20")
            ]
        )
    }
}
