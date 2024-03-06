//
//  RequestMethod.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation

public enum RequestMethod: String, Sendable {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}
