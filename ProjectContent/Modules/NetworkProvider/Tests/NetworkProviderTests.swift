//
//  NetworkProviderTests.swift
//  NetworkProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import NetworkProvider
import XCTest

final class NetworkProviderTests: XCTestCase {
    private var sut: NetworkProviderProtocol!

    override func setUp() {
        super.setUp()
        URLProtocolMock.setup()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)

        sut = NetworkProvider(session: session)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolMock.tearDown()
    }

    func testMakeRequest() async throws {
        URLProtocolMock.data = Data()
        URLProtocolMock.response = HTTPURLResponse(
            url: URL(string: #file)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["responseHeaderParam": "responseHeaderValue"]
        )!

        let request = NetworkRequest(
            endpoint: #file,
            body: "{}".data(using: .utf8),
            httpMethod: .post,
            queryParams: ["queryParam": "queryValue"],
            headers: [
                "headerParam": "headerValue",
                "Content-Length": "2" // added automatically
            ]
        )

        let response = try await sut.makeRequest(request)

        XCTAssertEqual(response.statusCode, URLProtocolMock.response?.statusCode)
        XCTAssertEqual(response.content, URLProtocolMock.data)
        XCTAssertEqual(response.headers.toNSDictionary(), URLProtocolMock.response?.allHeaderFields.toNSDictionary())

        XCTAssertEqual(request.endpoint + "?queryParam=queryValue", URLProtocolMock.request?.url?.absoluteString)
        XCTAssertEqual(request.body, URLProtocolMock.request?.httpBodyStream?.asData())
        XCTAssertEqual(request.httpMethod.rawValue, URLProtocolMock.request?.httpMethod)
        XCTAssertEqual(request.headers, URLProtocolMock.request?.allHTTPHeaderFields)
    }

    func testMakeDecodingRequest() async throws {
        URLProtocolMock.data = """
                {"thisShouldBeDecoded": "good to go"}
            """.data(using: .utf8)
        URLProtocolMock.response = HTTPURLResponse(
            url: URL(string: #file)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["responseHeaderParam": "responseHeaderValue"]
        )!

        let request = NetworkRequest(
            endpoint: #file,
            body: "{}".data(using: .utf8),
            httpMethod: .get,
            queryParams: ["queryParam": "queryValue"],
            headers: [
                "headerParam": "headerValue",
                "Content-Length": "2" // added automatically
            ]
        )

        let response: NetworkResponse<DecodableTest> = try await sut.makeRequest(request)

        XCTAssertEqual(response.statusCode, URLProtocolMock.response?.statusCode)
        XCTAssertEqual(response.content.thisShouldBeDecoded, "good to go")
        XCTAssertEqual(response.headers.toNSDictionary(), URLProtocolMock.response?.allHeaderFields.toNSDictionary())

        XCTAssertEqual(request.endpoint + "?queryParam=queryValue", URLProtocolMock.request?.url?.absoluteString)
        XCTAssertEqual(request.body, URLProtocolMock.request?.httpBodyStream?.asData())
        XCTAssertEqual(request.httpMethod.rawValue, URLProtocolMock.request?.httpMethod)
        XCTAssertEqual(request.headers, URLProtocolMock.request?.allHTTPHeaderFields)
    }

    func testMakeRequestWithRequestUrlError() async {
        do {
            _ = try await sut.makeRequest(NetworkRequest(endpoint: "http://[::1"))
            XCTFail("Error should be \(NetworkError.invalidUrl) but didn't throw")
        } catch {
            if case .invalidUrl = error as? NetworkError {} else {
                XCTFail("Error should be \(NetworkError.invalidUrl) but is \(error)")
            }
        }
    }

    func testMakeRequestWithInvalidResponseError() async {
        do {
            URLProtocolMock.data = Data()

            _ = try await sut.makeRequest(NetworkRequest(endpoint: #file))
            XCTFail("Error should be \(NetworkError.invalidResponse) but didn't throw")
        } catch {
            let error = (error as NSError)
            let expectedError = NetworkError.invalidResponse as NSError
            guard error.domain == expectedError.domain, error.code == expectedError.code else {                XCTFail("Error should be \(NetworkError.invalidResponse) but is \(error)")
                return
            }
        }
    }

    func testMakeRequestWithConnectionErrors() async {
        let connectionErrorCodes = [-1001, -1004, -1005, -1009]

        for errorCode in connectionErrorCodes {
            do {
                URLProtocolMock.error = NSError(domain: "__PROJECTNAMEIDENTIFIER__.NetworkError", code: errorCode)

                _ = try await sut.makeRequest(NetworkRequest(endpoint: #file))
                XCTFail("Error should be \(NetworkError.connection) but didn't throw")
            } catch {
                if case .connection = error as? NetworkError {} else {
                    XCTFail("Error should be \(NetworkError.connection) but is \(error)")
                }
            }
        }
    }

    func testMakeRequestWithGenericError() async {
        do {
            URLProtocolMock.error = NSError(domain: "testMakeRequestWithGenericError", code: -1)

            _ = try await sut.makeRequest(NetworkRequest(endpoint: #file))
            XCTFail("Error should be \(NetworkError.invalidResponse) but didn't throw")
        } catch {
            let error = (error as NSError)
            let expectedError = (URLProtocolMock.error! as NSError)
            guard error.domain == expectedError.domain, error.code == expectedError.code else {
                XCTFail("Error should be \(URLProtocolMock.error!) but is \(error)")
                return
            }
        }
    }

    func testMakeRequestWithdecoding() async {
        do {
            URLProtocolMock.data = "{}".data(using: .utf8)
            URLProtocolMock.response = HTTPURLResponse(
                url: URL(string: #file)!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let _: NetworkResponse<DecodableTest> = try await sut.makeRequest(NetworkRequest(endpoint: #file))
            XCTFail("Error should be \(NetworkError.invalidParams) but didn't throw")
        } catch {
            if case .decoding = error as? NetworkError {} else {
                XCTFail("Error should be \(String(describing: NetworkError.decoding)) but is \(error)")
            }
        }
    }
}

fileprivate struct DecodableTest: Decodable {
    let thisShouldBeDecoded: String
}
