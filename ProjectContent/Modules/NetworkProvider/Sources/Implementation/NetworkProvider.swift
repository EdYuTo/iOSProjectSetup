//
//  NetworkProvider.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public final class NetworkProvider {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private func buildRequest(with request: NetworkRequestProtocol) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: request.endpoint) else {
            throw NetworkError.invalidUrl
        }
        urlComponents.queryItems = request.queryParams?.compactMap { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = urlComponents.url else {
            throw NetworkError.invalidParams
        }

        var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpBody = request.body
        request.headers?.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}

// MARK: - NetworkProviderProtocol
extension NetworkProvider: NetworkProviderProtocol {
    public func makeRequest<T: Decodable>(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<T> {
        var statusCode = -1
        do {
            let response = try await makeRequest(request)
            statusCode = response.statusCode
            let content = try request.decoder.decode(T.self, from: response.content)
            return NetworkResponse(
                statusCode: response.statusCode,
                headers: response.headers,
                content: content
            )
        } catch let error as Swift.DecodingError {
            throw NetworkError.decoding(description: error.localizedDescription, statusCode: statusCode)
        } catch {
            throw error
        }
    }

    public func makeRequest(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<Data> {
        let urlRequest = try buildRequest(with: request)

        do {
            let result = try await session.data(for: urlRequest)
            let (data, response) = (result.0, result.1)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            return NetworkResponse(
                statusCode: response.statusCode,
                headers: response.allHeaderFields,
                content: data
            )
        } catch let error as NSError where error.code == NSURLErrorCancelled {
            throw NetworkError.cancelledRequest
        } catch let error as NSError where ConnectionError(rawValue: error.code) != nil {
            throw NetworkError.connection
        } catch {
            throw error
        }
    }
}
