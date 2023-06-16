import Foundation

class FileCache {
    static let header = "id;text;importance;deadLine;isDone;creationDate;lastChangeDate"
    
    private(set) var TodoItems: [TodoItem] = []
    
    func addTodoItem(_ newTodo: TodoItem) {
        for i in 0..<TodoItems.count {
            if TodoItems[i].id == newTodo.id {
                TodoItems[i] = newTodo
                return
            }
        }
        TodoItems.append(newTodo)
    }
    
    func removeTodoItemById(id: String) {
        var indexToRemove: Int?
        
        for i in 0..<TodoItems.count {
            if TodoItems[i].id == id {
                indexToRemove = i
                break
            }
        }
        
        if let indexToRemove {
            TodoItems.remove(at: indexToRemove)
        }
    }
    
    func saveTodosToFile(fileNameJson: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let json = TodoItems.map { $0.json }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            try? data.write(to: documentsURL.appendingPathComponent(fileNameJson))
        }
    }
    
    func loadTodosFromFile(fileNameJson: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if let data = try? Data(contentsOf: documentsURL.appendingPathComponent(fileNameJson)),
           let jsonRaw = try? JSONSerialization.jsonObject(with: data, options: []),
           let json = jsonRaw as? [[String: Any]] {
            TodoItems = []
            for item in json {
                if let tempTodo = TodoItem.parse(json: item) {
                    TodoItems.append(tempTodo)
                }
            }
        } else {
            // Error or SMTH
            // Data hasn't been loaded
        }
    }
    
    func saveTodosToFile(fileNameCsv: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        let data = Data((TodoItems.reduce(FileCache.header) { $0 + "\n" + $1.csv }).utf8)
        
        try? data.write(to: documentsURL.appendingPathComponent(fileNameCsv))
    }
    
    func loadTodosFromFile(fileNameCsv: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        if let dataRaw = try? Data(contentsOf: documentsURL.appendingPathComponent(fileNameCsv)) {
            let rows = String(decoding: dataRaw, as: UTF8.self).split(separator: "\n")
            if rows[0].trimmingCharacters(in: .whitespacesAndNewlines) == FileCache.header {
                TodoItems = []
                for i in 1..<rows.count {
                    if let tempTodo = TodoItem.parse(csv: String(rows[i])) {
                        TodoItems.append(tempTodo)
                    }
                }
            } else {
                // Error or SMTH
                // Incorrect header
            }
        } else {
            // Error or SMTH
            // Data hasn't been loaded
        }
    }
}
