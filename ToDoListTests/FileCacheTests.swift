import XCTest
@testable import ToDoList


final class FileCacheTests: XCTestCase {
    func testFileCacheJson() throws {
        let fileCache = FileCache()
        let newCache = FileCache()

        let item1 = TodoItem(id: "1",
                             text: "bla bla bla",
                             importance: .important,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: nil)
        let item2 = TodoItem(id: "2",
                             text: "bla bla bla",
                             importance: .low,
                             deadLine: nil,
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))
        let item3 = TodoItem(id: "3",
                             text: "bla bla bla",
                             importance: .basic,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: true,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))

        fileCache.addTodoItem(item1)
        fileCache.addTodoItem(item2)
        fileCache.addTodoItem(item3)

        try? fileCache.saveTodosToFile(fileNameJson: "test1.json")
        try? newCache.loadTodosFromFile(fileNameJson: "test1.json")

        XCTAssertEqual(fileCache.todoItems, newCache.todoItems)
    }

    func testFileCacheCsv() throws {
        let fileCache = FileCache()
        let newCache = FileCache()

        let item1 = TodoItem(id: "1",
                             text: "bla bla bla",
                             importance: .important,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: nil)
        let item2 = TodoItem(id: "2",
                             text: "bla bla bla",
                             importance: .low,
                             deadLine: nil,
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))
        let item3 = TodoItem(id: "3",
                             text: "bla bla bla",
                             importance: .basic,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: true,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))

        fileCache.addTodoItem(item1)
        fileCache.addTodoItem(item2)
        fileCache.addTodoItem(item3)

        try? fileCache.saveTodosToFile(fileNameCsv: "test1.csv")
        try? newCache.loadTodosFromFile(fileNameCsv: "test1.csv")

        XCTAssertEqual(fileCache.todoItems, newCache.todoItems)
    }
}
