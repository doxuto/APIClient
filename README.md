[![CI](https://github.com/doxuto/APIClient/actions/workflows/ci.yml/badge.svg)](https://github.com/doxuto/APIClient/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5.5_|_5.6_|_5.7_|_5.8_|_5.9-red)](https://img.shields.io/badge/Swift-5.5_5.6_5.7_5.8_5.9-red)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_|_iOS-red)](https://img.shields.io/badge/Platforms-macOS_iOS-red)
### README.md

```markdown
# APIClient

## Description
A simply networking layer in Swift that allows you to easily make HTTP requests and handle response data.

## Installation
To use the APIClient module in your Swift project, include this package as a dependency in your Package.swift file.

```swift
dependencies: [
    .package(url: "https://github.com/doxuto/APIClient.git", from: "1.0.0")
]
```

## Usage
1. Import the APIClient module in your Swift files where you need to make API requests.

```swift
import APIClient

struct UserEndpoint: Endpoint {
    var url: URL = URL(string: "https://httpbin.org/get")!
    var requestMethod: RequestMethod = RequestMethod.get
    var headers: [String : String]? = nil
    var parameters: [String : String]? = nil
    var timeoutInterval: TimeInterval = 60
}

let apiClient = APIClient(
            validator: DefaultValidator(),
            urlSession: URLSession.shared,
            jsonDecoder: JSONDecoder()
)
        
let endpoint = UserEndpoint()
let user: User = try await apiClient.request(endpoint: endpoint)
```

Or you can use Combine's `Publisher` type to handle API responses.
```
 func fetchUser() -> AnyPublisher<User, Error> {
    let endpoint = UserEndpoint()
    return apiClient.request(endpoint: endpoint)
 }
    
```

2. If you want to customize the `Validator` of APIClient, you can do that in the contructor `APIClient`
```
struct CustomizedValidator: Validator {
    func validate(for response: HTTPURLResponse) throw -> Bool {
        let statusCode = response.statusCode
        return statusCode == 200
    }
}

let apiClient = APIClient(
            validator: CustomizedValidator(),
            urlSession: URLSession.shared,
            jsonDecoder: JSONDecoder()
)
        
let endpoint = UserEndpoint()
let user: User = try await apiClient.request(endpoint: endpoint)

```


## Dependencies
- No external dependencies required.

## Structure
- **APIClient:** Main module for handling API requests.
- **APIClientTests:** Unit tests for the APIClient module.

## Contribution
Feel free to contribute by forking the repository and submitting pull requests.

## License
This package is released under the MIT License. See LICENSE file for more details.
```
