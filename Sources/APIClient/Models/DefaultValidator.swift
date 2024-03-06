//
//  DefaultValidator.swift
//
//
//  Created by doxuto on 05/03/2024.
//

import Foundation

struct DefaultValidator: Validator {
    let filteredStatusCodes = 200...299
    func validate(for response: HTTPURLResponse) -> Bool {
        let statusCode = response.statusCode
        return filteredStatusCodes.contains(statusCode)
    }
}
