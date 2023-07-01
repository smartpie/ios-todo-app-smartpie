import Foundation

class TodoListHandler {
    static let fileCache = FileCache()
    private(set) var todoItem: TodoItem?

    init() {
        loadItems()
    }

    //MARK: - Methods
    func addItem(_ item: TodoItem) {
        print(item)
        todoItem = item
        TodoListHandler.fileCache.addTodoItem(item)
        print(TodoListHandler.fileCache.todoItems)
        saveItems()
    }

    func deleteItem() {
        todoItem = nil
        TodoListHandler.fileCache.removeAllTodoItems()
        saveItems()
    }

    func saveItems() {
        do {
            try TodoListHandler.fileCache.saveTodosToFile(fileNameJson: "one.json")
            print("Saved to JSON")
        } catch {
            print("Error while trying to save to JSON")
        }
    }

    func loadItems() {
        do {
            try TodoListHandler.fileCache.loadTodosFromFile(fileNameJson: "one.json")
            print(TodoListHandler.fileCache.todoItems)
            if TodoListHandler.fileCache.todoItems.count == 0 {
                print("There was no saved TodoItem")
            } else {
                todoItem = TodoListHandler.fileCache.todoItems[0]
                print("Loaded to JSON")
            }

        } catch {
            print("Error while trying to load from JSON")
        }
    }
}
