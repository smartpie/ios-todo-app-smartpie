import Foundation

enum RequestProcessorError: Error {
    case wrongUrl(URLComponents)
    case unexpectedResponse(URLResponse)
    case failedResponse(URLResponse)
    case parsingFail
    case convercingFail
    case noItemWithIdentifier(String)
}

class DefaultNetworkingService: NetworkingService {

    private let urlSession: URLSession
    private let deviceID: String
    private var revision: Int32 = 0

    init(deviceID: String, urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.deviceID = deviceID
    }

    // MARK: - Main functions
    func getList() async throws -> [TodoItem] {
        print("getList Started")

        let url = try makeUrl(path: "/list")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy
        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todos = json["list"] as? [[String: Any]],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        var todoItems: [TodoItem] = []
        for todo in todos {
            if let todo = TodoItem.parse(json: todo) {
                todoItems.append(todo)
            }
        }

        print("getList Ended")
        return todoItems
    }

    func patchList(todoItems: [TodoItem]) async throws -> [TodoItem] {
        print("patchList Started")

        let url = try makeUrl(path: "/list")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy

        let todoItemsJson = todoItems.map { $0.getJsonForNet(deviceID: deviceID) } as! [[String: Any]]
        let json: [String: Any] = [
            "status": "ok",
            "list": todoItemsJson
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            throw RequestProcessorError.convercingFail
        }
        request.httpBody = body

        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todos = json["list"] as? [[String: Any]],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        var todoItems: [TodoItem] = []
        for todo in todos {
            if let todo = TodoItem.parse(json: todo) {
                todoItems.append(todo)
            }
        }

        print("patchList Ended")
        return todoItems
    }

    func getItemById(id: String) async throws -> TodoItem? {
        print("getItemById Started")

        let url = try makeUrl(path: "/list/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy

        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        if response.statusCode == 404 {
            return nil
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todo = json["element"] as? [String: Any],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        print("getItemById Ended")

        if let newTodoItem = TodoItem.parse(json: todo) {
            return newTodoItem
        }

        return nil
    }

    @discardableResult
    func postItem(todoItem: TodoItem) async throws -> TodoItem? {
        print("postItemById Started")

        let url = try makeUrl(path: "/list")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy

        let json: [String: Any] = [
            "status": "ok",
            "element": todoItem.getJsonForNet(deviceID: self.deviceID)
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            throw RequestProcessorError.convercingFail
        }

        request.httpBody = body

//        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            throw FileCacheErrors.unableToFindDocumentsDirectory
//        }
//        do {
//            try body.write(to: documentsURL.appendingPathComponent("pamagiti2.json"))
//        } catch {
//            print("Some error while saving data: \(error)")
//        }
//
//        print(documentsURL.appendingPathComponent("pamagiti2.json"))
//        print(body)
//        print(revision)

        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todo = json["element"] as? [String: Any],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        print("postItemById Ended")

        if let newTodoItem = TodoItem.parse(json: todo) {
            return newTodoItem
        }

        return nil
    }

    // Same as the postItem exept it is PUT, not POST
    // I need to fix it later
    @discardableResult
    func putItem(todoItem: TodoItem) async throws -> TodoItem? {
        print("putItemById Started")

        let url = try makeUrl(path: "/list/\(todoItem.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy

        let json: [String: Any] = [
            "status": "ok",
            "element": todoItem.getJsonForNet(deviceID: self.deviceID)
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            throw RequestProcessorError.convercingFail
        }

        request.httpBody = body

        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        if response.statusCode == 404 {
            print("\nThere is no task with id:\(todoItem.id)\nTrying POST instead of PUT\n")
            return try await postItem(todoItem: todoItem)
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todo = json["element"] as? [String: Any],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        print("putItemById Ended")

        if let newTodoItem = TodoItem.parse(json: todo) {
            return newTodoItem
        }

        return nil
    }

    @discardableResult
    func deleteItemById(id: String) async throws -> TodoItem? {
        print("deleteItemById Started")

        let url = try makeUrl(path: "/list/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.setValue(config.fails, forHTTPHeaderField: "X-Generate-Fails")
        request.timeoutInterval = config.timeOut
        request.cachePolicy = .useProtocolCachePolicy

        let (data, response) = try await urlSession.dataTask(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw RequestProcessorError.unexpectedResponse(response)
        }
        guard response.statusCode != 404 else {
            print("\nThere is no task with id:\(id)\n")
            throw RequestProcessorError.noItemWithIdentifier(id)
        }
        guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
            print("Code: \(response.statusCode)")
            throw RequestProcessorError.failedResponse(response)
        }
        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [String: Any],
              let todo = json["element"] as? [String: Any],
              let newRevision = json["revision"] as? Int32 else {
            throw RequestProcessorError.parsingFail
        }

        self.revision = newRevision

        print("deleteItemById Ended")

        if let newTodoItem = TodoItem.parse(json: todo) {
            return newTodoItem
        }

        return nil
    }

    // MARK: - Private Stuff
    private static let httpStatusCodeSuccess = 200..<300

    private struct config {
        static let scheme = "https"
        static let host = "beta.mrdekk.ru"
        static let basePath = "/todobackend/"
        static let token = "dispensers"
        static let fails = "-1"
        static let timeOut: TimeInterval = 30
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
