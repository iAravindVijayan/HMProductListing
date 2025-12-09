//
//  Untitled.swift
//  Localisation
//
//  Created by Aravind Vijayan on 2025-12-08.
//

import Foundation

public enum UIStrings: String {
    //MARK: Errors
    case networkError = "error.network"
    case invalidUrl = "error.invalidUrl"
    case decodingError = "error.decoding"
    case noDataError = "error.noData"

    //MARK: General
    case ok = "general.ok"

    public var localized: String {
        self.rawValue.localized
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
