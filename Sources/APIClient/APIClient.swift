//
//  APIClient.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation
import Combine

public struct APIClient {
    private let validator: any Validator
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    public init(validator: any Validator, urlSession: URLSession, jsonDecoder: JSONDecoder) {
        self.validator = validator
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    public func request(endpoint: any Endpoint) async throws -> Data {
        let urlRequest = endpoint.toRequest
        let data: Data
        let urlResponse: URLResponse
        do {
            let response = try await urlSession.data(for: urlRequest)
            data = response.0
            urlResponse = response.1 as! HTTPURLResponse
        } catch {
            throw ApiError.underlying(error)
        }
        
        guard try validator.validate(for: urlResponse as! HTTPURLResponse) else {
            throw ApiError.invalid
        }
        return data
    }
    
    public func request<T: Decodable>(endpoint: any Endpoint) async throws -> T {
        let data = try await self.request(endpoint: endpoint)
        do {
            let result = try jsonDecoder.decode(T.self, from: data)
            return result
        } catch {
            throw ApiError.parseError(error)
        }
    }
    
    public func request<T: Decodable>(endpoint: any Endpoint) -> AnyPublisher<T, Error> {
        urlSession.dataTaskPublisher(for: endpoint.toRequest)
            .tryMap { try process(data: $0, response: $1) }
            .eraseToAnyPublisher()
    }
    
    private func process<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        let httpResponse = response as! HTTPURLResponse
        guard try validator.validate(for: httpResponse) else { throw ApiError.invalid }
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw ApiError.parseError(error)
        }
    }
}
