//
//  Validator.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation

public protocol Validator {
    func validate(for response: HTTPURLResponse) throws -> Bool
}
