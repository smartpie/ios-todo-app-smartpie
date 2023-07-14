import UIKit
import SQLite

@MainActor
public final class SQLiteManager {
    public static let shared = try! SQLiteManager()

    private let db: Connection
    private let todos: Table
    private let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"

    init() throws {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        print("SQLite DB url: \(path)")

        db = try Connection("\(path)/db.sqlite3")

        todos = Table("todos")

        try db.run(todos.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text)
            t.column(importance)
            t.column(deadline)
            t.column(done)
            t.column(created_at)
            t.column(changed_at)
            t.column(last_updated_by)
        })
    }

    // MARK: - Fields
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadline = Expression<Date?>("deadline")
    private let done = Expression<Bool>("done")
    private let created_at = Expression<Date>("created_at")
    private let changed_at = Expression<Date?>("changed_at")
    private let last_updated_by = Expression<String>("last_updated_by")

    // MARK: - CRUD Functions
    public func createTodo(_ todoItem: TodoItem) throws {
        try db.run(todos.insert(or: .replace,
                                id <- todoItem.id,
                                text <- todoItem.text,
                                importance <- todoItem.importance.rawValue,
                                deadline <- todoItem.deadLine,
                                done <- todoItem.isDone,
                                created_at <- todoItem.creationDate,
                                changed_at <- todoItem.lastChangeDate,
                                last_updated_by <- deviceId))
    }

    public func fetchTodoList() throws -> [TodoItem] {
        var todoList: [TodoItem] = []
        for todo in try db.prepare(todos) {
            todoList.append(TodoItem(id: todo[id],
                                     text: todo[text],
                                     importance: Importance(rawValue: todo[importance]) ?? .basic,
                                     deadLine: todo[deadline],
                                     isDone: todo[done],
                                     creationDate: todo[created_at],
                                     lastChangeDate: todo[changed_at]))
        }

        return todoList
    }

    public func updateTodo(_ todoItem: TodoItem) throws {
        // А зачем что-то усложнять, если всё и так хорошо
        try createTodo(todoItem)
    }

    public func deleteTodoList() throws {
        try db.run(todos.delete())
    }

    public func deleteTodo(id id1: String) throws {
        let todoItem = todos.filter(id == id1)
        try db.run(todoItem.delete())
    }
}
