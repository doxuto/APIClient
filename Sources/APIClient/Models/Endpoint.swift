//
//  Endpoint.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation

public protocol Endpoint {
    var url: URL { get }
    var requestMethod: RequestMethod { get }
    var headers: [String: String]? { get }
    var timeoutInterval: TimeInterval { get }
    var parameters: [String: String]? { get }
}

public extension Endpoint {
    var timeoutInterval: TimeInterval { 60 }
}

public extension Endpoint {
    var toRequest: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters as Any, options: .fragmentsAllowed)
        return urlRequest
    }
}
