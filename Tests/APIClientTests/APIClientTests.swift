import Combine
import XCTest
@testable import APIClient

final class APIClientTests: XCTestCase {
    lazy var dataFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return dateFormatter
    }()
    
    lazy var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(self.dataFormatter)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }()
    
    var apiClient: APIClient!
    var cancelables = Set<AnyCancellable>()
    
    override func setUp() async throws {
        apiClient = .init(
            validator: DefaultValidator(),
            urlSession: urlSession,
            jsonDecoder: jsonDecoder
        )
        cancelables = []
    }
    
    func test_fetchUser_success_with_data_response_success() async throws {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJson.data(using: .utf8), response: response)
        
        let userData = try await apiClient.request(endpoint: endpoint)
        let user = try jsonDecoder.decode(User.self, from: userData)
        XCTAssertEqual(user.email, "test@test.com")
    }
    
    func test_fetchUser_success_with_invalid_statusCode() async throws {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJson.data(using: .utf8), response: response)
        
        do {
            let _ = try await apiClient.request(endpoint: endpoint)
        } catch {
            XCTAssertEqual(error as? ApiError, ApiError.invalid)
        }
    }
    
    func test_fetchUser_with_decode_success() async throws {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJson.data(using: .utf8), response: response)
        
        let user: User = try await apiClient.request(endpoint: endpoint)
        XCTAssertEqual(user.email, "test@test.com")
    }
    
    func test_fetchUser_with_decode_invalid_statusCode() async throws {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJson.data(using: .utf8), response: response)
        
        do {
            let _: User = try await apiClient.request(endpoint: endpoint)
        } catch {
            XCTAssertEqual(error as? ApiError, ApiError.invalid)
        }
    }
    
    func test_fetchUser_with_decode_failure() async throws {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJsonWithTimestamp.data(using: .utf8), response: response)
        
        do {
            let _: User = try await apiClient.request(endpoint: endpoint)
        } catch {
            XCTAssertEqual(error as? ApiError, ApiError.parseError(error))
        }
    }
    
    func test_fetchUser_use_publisher_with_decode_success() {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJson.data(using: .utf8), response: response)
        
        let expectation = XCTestExpectation(description: "Receive a user after fetch data")
        var user: User?
        
        let userPublisher: AnyPublisher<User, any Error> = apiClient.request(endpoint: endpoint)
        
        userPublisher.sink(
            receiveCompletion: { _ in
            },
            receiveValue: { value in
                user = value
                expectation.fulfill()
            })
        .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(user?.email, "test@test.com")
    }
    
    func test_fetchUser_use_publisher_with_decode_failure() {
        let endpoint = UserEndpoint()
        let response = HTTPURLResponse(
            url: endpoint.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: endpoint.headers
        )
        
        MockURLProtocol.mockURLs[endpoint.url] = (error: nil, data: userJsonWithTimestamp.data(using: .utf8), response: response)
        
        let expectation = XCTestExpectation(description: "Receive an error")
        var error: ApiError?
        
        let userPublisher: AnyPublisher<User, any Error> = apiClient.request(endpoint: endpoint)
        
        userPublisher.sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    error = failure as? ApiError
                    expectation.fulfill()
                }
            },
            receiveValue: { _ in
            })
        .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(error, ApiError.parseError(NSError()))
    }
}

extension ApiError: Equatable {
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.invalid, .invalid):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.parseError, .parseError):
            return true
        case (.underlying, .underlying):
            return true
        default:
            return false
        }
    }
}

struct UserEndpoint: Endpoint {
    var url: URL = URL(string: "https://httpbin.org/get")!
    var requestMethod: RequestMethod = RequestMethod.get
    var headers: [String : String]? = nil
    var parameters: [String : String]? = nil
    var timeoutInterval: TimeInterval = 60
}
