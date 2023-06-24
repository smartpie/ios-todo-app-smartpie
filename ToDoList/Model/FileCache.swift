import Foundation

enum FileCacheErrors: Error {
    case unableToFindDocumentsDirectory
    case unableToLoadData
    case unableToConvertToJson
    case unableToParseData
    case incorrectHeader
}

class FileCache {
    static let header = "id;text;importance;deadLine;isDone;creationDate;lastChangeDate"
    
    private(set) var TodoItems: [String: TodoItem] = [:]

    @discardableResult
    func addTodoItem(_ newTodo: TodoItem) -> TodoItem? {
        let oldTodoItem = TodoItems[newTodo.id]
        TodoItems[newTodo.id] = newTodo
        return oldTodoItem
    }

    @discardableResult
    func removeTodoItemById(_ id: String) -> TodoItem? {
        let oldTodoItem = TodoItems[id]
        TodoItems[id] = nil
        return oldTodoItem
    }

}

// MARK: - JSON
extension FileCache {
    func saveTodosToFile(fileNameJson: String) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.unableToFindDocumentsDirectory
        }
        
        let json = TodoItems.map { $0.value.json }

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            throw FileCacheErrors.unableToConvertToJson
        }

        do {
            try data.write(to: documentsURL.appendingPathComponent(fileNameJson))
        } catch {
            print("Some error while saving data: \(error)")
        }
    }
    
    func loadTodosFromFile(fileNameJson: String) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.unableToFindDocumentsDirectory
        }
        
        guard let data = try? Data(contentsOf: documentsURL.appendingPathComponent(fileNameJson)) else {
            throw FileCacheErrors.unableToLoadData
        }

        guard let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
              let json = jsonRaw as? [[String: Any]] else {
            throw FileCacheErrors.unableToParseData
        }

        TodoItems = [:]
        for item in json {
            if let tempItem = TodoItem.parse(json: item) {
                TodoItems[tempItem.id] = tempItem
            }
        }
    }
}

// MARK: - CSV
extension FileCache {
    func saveTodosToFile(fileNameCsv: String) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.unableToFindDocumentsDirectory
        }
        
        let data = Data((TodoItems.reduce(FileCache.header) { $0 + "\n" + $1.value.csv }).utf8)
        
        do {
            try data.write(to: documentsURL.appendingPathComponent(fileNameCsv))
        } catch {
            print("Some error while saving data: \(error)")
        }
    }
    
    func loadTodosFromFile(fileNameCsv: String) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.unableToFindDocumentsDirectory
        }

        guard let dataRaw = try? Data(contentsOf: documentsURL.appendingPathComponent(fileNameCsv)) else {
            throw FileCacheErrors.unableToLoadData
        }

        let rows = String(decoding: dataRaw, as: UTF8.self).split(separator: "\n")
        if rows[0].trimmingCharacters(in: .whitespacesAndNewlines) == FileCache.header {
            TodoItems = [:]
            for i in 1..<rows.count {
                if let tempItem = TodoItem.parse(csv: String(rows[i])) {
                    TodoItems[tempItem.id] = tempItem
                }
            }
        } else {
            throw FileCacheErrors.incorrectHeader
        }
    }
}
