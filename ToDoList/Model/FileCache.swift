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
    
    private(set) var todoItems: [TodoItem] = []

    @discardableResult
    func addTodoItem(_ newTodo: TodoItem) -> TodoItem? {
        if let oldIndex = todoItems.firstIndex(where: { $0.id == newTodo.id} ) {
            let oldTodoItem = todoItems[oldIndex]
            todoItems[oldIndex] = newTodo
            return oldTodoItem
        }
        todoItems.append(newTodo)
        return nil
    }

    @discardableResult
    func removeTodoItemById(_ id: String) -> TodoItem? {
        if let oldIndex = todoItems.firstIndex(where: { $0.id == id} ) {
            let oldTodoItem = todoItems[oldIndex]
            todoItems.remove(at: oldIndex)
            return oldTodoItem
        }
        return nil
    }

    func removeAllTodoItems() { // ONLY FOR TESTING
        todoItems = []
    }

}

// MARK: - JSON
extension FileCache {
    func saveTodosToFile(fileNameJson: String) throws {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.unableToFindDocumentsDirectory
        }

        let json = todoItems.map { $0.json }

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

        todoItems = []
        for item in json {
            if let tempItem = TodoItem.parse(json: item) {
                todoItems.append(tempItem)
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
        
        let data = Data((todoItems.reduce(FileCache.header) { $0 + "\n" + $1.csv }).utf8)
        
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
            todoItems = []
            for i in 1..<rows.count {
                if let tempItem = TodoItem.parse(csv: String(rows[i])) {
                    todoItems.append(tempItem)
                }
            }
        } else {
            throw FileCacheErrors.incorrectHeader
        }
    }
}
