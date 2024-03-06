//
//  MockURLProtocol.swift
//
//
//  Created by doxuto on 06/03/2024.
//

import Foundation

class MockURLProtocol: URLProtocol {
    /// Dictionary maps URLs to tuples of error, data, and response
    static var mockURLs = [URL?: (error: Error?, data: Data?, response: HTTPURLResponse?)]()
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Handle all types of requests
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Required to be implemented here. Just return what is passed
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            if let (error, data, response) = Self.mockURLs[url] {
                
                // We have a mock response specified so return it.
                if let responseStrong = response {
                    self.client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
                }
                
                // We have mocked data specified so return it.
                if let dataStrong = data {
                    self.client?.urlProtocol(self, didLoad: dataStrong)
                }
                
                // We have a mocked error so return it.
                if let errorStrong = error {
                    self.client?.urlProtocol(self, didFailWithError: errorStrong)
                }
            }
        }
        
        // Send the signal that we are done returning our mock response
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Required to be implemented. Do nothing here.
    }
}
