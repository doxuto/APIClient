//
//  ApiError.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation

public enum ApiError: Error, Sendable {
    case invalid
    case badRequest
    case underlying(Error)
    case parseError(Error)
}
