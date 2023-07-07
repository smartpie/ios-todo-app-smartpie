import Foundation

enum RequestProcessorError: Error {
    case wrongUrl(URLComponents)
    case unexpectedResponse(URLResponse)
    case failedResponse(URLResponse)
}

class DefaultNetworkingService {

    private let urlSession: URLSession = .shared

    func getList() async throws -> [TodoItem] {
        let url = try makeUrl(path: "/list")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = 10
        request.cachePolicy = .useProtocolCachePolicy
        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            print("Ooops")
            throw RequestProcessorError.unexpectedResponse(response)
        }

        print(response.statusCode)

        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            throw RequestProcessorError.failedResponse(response)
        }

        print(response)

        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw FileCacheErrors.unableToParseData
        }


        print(jsonRaw)

        return []
    }

    private static let httpStatusCodeSuccess = 200..<300

    private struct config {
        static let scheme = "https"
        static let host = "beta.mrdekk.ru"
        static let basePath = "/todobackend/"
        static let token = "dispensers"
        static let fails = "50"
    }

    private func makeUrl(path: String) throws -> URL {
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = config.host
        components.path = "\(config.basePath)/\(path)"

        guard let url = components.url else {
            throw RequestProcessorError.wrongUrl(components)
        }

        return url
    }
}
