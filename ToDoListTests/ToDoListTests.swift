import XCTest
@testable import ToDoList

final class ToDoListTests: XCTestCase {
    // –––––––––– CSV ––––––––––
    // ––Parse––
    func testTodoItemParceCsv() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;222"), item)
    }
    // Id
    func testTodoItemParceCsvMissingId() throws {
        XCTAssertEqual(TodoItem.parse(csv: ";bla bla bla;важная;333;false;111;222"), nil)
    }
    // Text
    func testTodoItemParceCsvMissingText() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;;важная;333;false;111;222"), nil)
    }
    // Importance
    func testTodoItemParceCsvMissingImportance() throws {
        let item = TodoItem(id: "1",
                            importance: .basic,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;;333;false;111;222"), item)
    }
    func testTodoItemParceCsvIncorrectImportance() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;влажная;333;false;111;222"), nil)
    }
    // DeadLine
    func testTodoItemParceCsvMissingDeadLine() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: nil,
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;;false;111;222"), item)
    }
    func testTodoItemParceCsvIncorrectDeadLine() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;пупупу;false;111;222"), nil)
    }
    // IsDone
    func testTodoItemParceCsvMissingIsDone() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;;111;222"), nil)
    }
    func testTodoItemParceCsvIncorrectIsDobe() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;fas;111;222"), nil)
    }
    // CreationDate
    func testTodoItemParceCsvMissingCreationDate() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;;222"), nil)
    }
    func testTodoItemParceCsvIncorrectCreationDate() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;я родился;222"), nil)
    }
    // LastChangeDate
    func testTodoItemParceCsvMissingLastChangeDate() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: nil,
                            text: "bla bla bla")
        
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;"), item)
    }
    func testTodoItemParceCsvIncorrectLastChangeDate() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;я упал на землю"), nil)
    }
    
    // ––Create––
    func testTodoItemCreateCsv() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;333;false;111;222")
    }
    // Importance
    func testTodoItemCreateCsvBasicImportance() throws {
        let item = TodoItem(id: "1",
                            importance: .basic,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(item.csv, "1;bla bla bla;;333;false;111;222")
    }
    // DeadLine
    func testTodoItemCreateCsvMissingDeadLine() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: nil,
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;;false;111;222")
    }
    // LastChangeDate
    func testTodoItemCreateCsvMissingLastChangeDate() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: nil,
                            text: "bla bla bla")
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;333;false;111;")
    }
    
    
    
    
    
    // –––––––––– JSON ––––––––––
    // ––Parse––
    func testTodoItemParceJson() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), item)
    }
    // Id
    func testTodoItemParceJsonMissingId() throws {
        let sut: [String: Any] = ["text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonEmptyId() throws {
        let sut: [String: Any] = ["id": "",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // Text
    func testTodoItemParceJsonMissingText() throws {
        let sut: [String: Any] = ["id": "1",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonEmptyText() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // Importance
    func testTodoItemParceJsonMissingImportance() throws {
        let item = TodoItem(id: "1",
                            importance: .basic,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), item)
    }
    func testTodoItemParceJsonEmptyImportance() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonIncorrectImportance() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "ffa",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // DeadLine
    func testTodoItemParceJsonMissingDeadLine() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: nil,
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222),
                            text: "bla bla bla")
        
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), item)
    }
    func testTodoItemParceJsonEmptyDeadLine() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": "",
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonIncorrectDeadLine() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": "333",
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // IsDone
    func testTodoItemParceJsonMissingIsDone() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonEmptyIsDone() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": "",
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonIncorrectIsDone() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": "false",
                                  "creationDate": 111,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // CreationDate
    func testTodoItemParceJsonMissingCreationDate() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonEmptyCreationDate() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": "",
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonIncorrectCreationDate() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": "111",
                                  "lastChangeDate": 222]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    // LastChangeDate
    func testTodoItemParceJsonMissingLastChangeDate() throws {
        let item = TodoItem(id: "1",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: nil,
                            text: "bla bla bla")
        
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111]
        
        XCTAssertEqual(TodoItem.parse(json: sut), item)
    }
    func testTodoItemParceJsonEmptyLastChangeDate() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": ""]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    func testTodoItemParceJsonIncorrectLastChangeDate() throws {
        let sut: [String: Any] = ["id": "1",
                                  "text": "bla bla bla",
                                  "importance": "важная",
                                  "deadLine": 333,
                                  "isDone": false,
                                  "creationDate": 111,
                                  "lastChangeDate": "222"]
        
        XCTAssertEqual(TodoItem.parse(json: sut), nil)
    }
    
    // ––Create––
    func testTodoItemCreateJson() throws {
        let sut = TodoItem(id: "1",
                           importance: .important,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222),
                           text: "bla bla bla")
        
        let item: [String: Any] = ["id": "1",
                                   "text": "bla bla bla",
                                   "importance": "важная",
                                   "deadLine": 333,
                                   "isDone": false,
                                   "creationDate": 111,
                                   "lastChangeDate": 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])["id"] as! String, item["id"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["text"] as! String, item["text"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["importance"] as? String, item["importance"] as? String)
        XCTAssertEqual((sut.json as! [String: Any])["deadLine"] as? Int, item["deadLine"] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])["isDone"] as! Bool, item["isDone"] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])["creationDate"] as! Int, item["creationDate"] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])["lastChangeDate"] as? Int, item["lastChangeDate"] as? Int)
    }
    // Importance
    func testTodoItemCreateJsonBasicImportance() throws {
        let sut = TodoItem(id: "1",
                           importance: .basic,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222),
                           text: "bla bla bla")
        
        let item: [String: Any] = ["id": "1",
                                   "text": "bla bla bla",
                                   "deadLine": 333,
                                   "isDone": false,
                                   "creationDate": 111,
                                   "lastChangeDate": 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])["id"] as! String, item["id"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["text"] as! String, item["text"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["importance"] as? String, item["importance"] as? String)
        XCTAssertEqual((sut.json as! [String: Any])["deadLine"] as? Int, item["deadLine"] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])["isDone"] as! Bool, item["isDone"] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])["creationDate"] as! Int, item["creationDate"] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])["lastChangeDate"] as? Int, item["lastChangeDate"] as? Int)
    }
    // DeadLine
    func testTodoItemCreateJsonMissingDeadLine() throws {
        let sut = TodoItem(id: "1",
                           importance: .important,
                           deadLine: nil,
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222),
                           text: "bla bla bla")
        
        let item: [String: Any] = ["id": "1",
                                   "text": "bla bla bla",
                                   "importance": "важная",
                                   "isDone": false,
                                   "creationDate": 111,
                                   "lastChangeDate": 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])["id"] as! String, item["id"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["text"] as! String, item["text"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["importance"] as? String, item["importance"] as? String)
        XCTAssertEqual((sut.json as! [String: Any])["deadLine"] as? Int, item["deadLine"] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])["isDone"] as! Bool, item["isDone"] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])["creationDate"] as! Int, item["creationDate"] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])["lastChangeDate"] as? Int, item["lastChangeDate"] as? Int)
    }
    // LastChangeDate
    func testTodoItemCreateJsonMissingLastChangeDate() throws {
        let sut = TodoItem(id: "1",
                           importance: .important,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: nil,
                           text: "bla bla bla")
        
        let item: [String: Any] = ["id": "1",
                                   "text": "bla bla bla",
                                   "importance": "важная",
                                   "deadLine": 333,
                                   "isDone": false,
                                   "creationDate": 111]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])["id"] as! String, item["id"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["text"] as! String, item["text"] as! String)
        XCTAssertEqual((sut.json as! [String: Any])["importance"] as? String, item["importance"] as? String)
        XCTAssertEqual((sut.json as! [String: Any])["deadLine"] as? Int, item["deadLine"] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])["isDone"] as! Bool, item["isDone"] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])["creationDate"] as! Int, item["creationDate"] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])["lastChangeDate"] as? Int, item["lastChangeDate"] as? Int)
    }
}
