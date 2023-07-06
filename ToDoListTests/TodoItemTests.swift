import XCTest
@testable import ToDoList

final class ToDoListTests: XCTestCase {
    // MARK: CSV Parsing
    func testTodoItemParceCsv() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;222"), item)
    }

    func testTodoItemParceCsvMissingField() throws {
        let item1 = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .basic,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        let item2 = TodoItem(id: "1",
                                   text: "bla bla bla",
                                   importance: .important,
                                   isDone: false,
                                   creationDate: Date(timeIntervalSince1970: 111),
                                   lastChangeDate: Date(timeIntervalSince1970: 222))
        let item3 = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111))

        XCTAssertEqual(TodoItem.parse(csv: ";bla bla bla;важная;333;false;111;222"), nil)   // id
        XCTAssertEqual(TodoItem.parse(csv: "1;;важная;333;false;111;222"), nil)             // text
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;;333;false;111;222"), item1)      // importance
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;;false;111;222"), item2)   // deadLine
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;;111;222"), nil)       // idDone
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;;222"), nil)     // creationDate
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;"), item3)   // lastChangeDate
    }

    func testTodoItemParceCsvIncorrectField() throws {
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;влажная;333;false;111;222"), nil)         // importance
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;пупупу;false;111;222"), nil)       // deadLine
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;fas;111;222"), nil)            // idDone
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;я родился;222"), nil)    // creationDate
        XCTAssertEqual(TodoItem.parse(csv: "1;bla bla bla;важная;333;false;111;я упал на землю"), nil)  // lastChangeDate
    }
    
    // MARK: - CSV Creatoin
    func testTodoItemCreateCsv() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;333;false;111;222")
    }
    // Importance
    func testTodoItemCreateCsvBasicImportance() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .basic,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        
        XCTAssertEqual(item.csv, "1;bla bla bla;;333;false;111;222")
    }
    // DeadLine
    func testTodoItemCreateCsvMissingDeadLine() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: nil,
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;;false;111;222")
    }
    // LastChangeDate
    func testTodoItemCreateCsvMissingLastChangeDate() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: nil)
        
        XCTAssertEqual(item.csv, "1;bla bla bla;важная;333;false;111;")
    }

    // MARK: - JSON Parsing
    func testTodoItemParceJson() throws {
        let item = TodoItem(id: "1",
                            text: "bla bla bla",
                            importance: .important,
                            deadLine: Date(timeIntervalSince1970: 333),
                            isDone: false,
                            creationDate: Date(timeIntervalSince1970: 111),
                            lastChangeDate: Date(timeIntervalSince1970: 222))
        let json: [String: Any] = [kId: "1",
                                 kText: "bla bla bla",
                           kImportance: "важная",
                             kDeadline: 333,
                               kIsDone: false,
                            kCreationDate: 111,
                            kLastChangeDate: 222]
        
        XCTAssertEqual(TodoItem.parse(json: json), item)
    }

    func testTodoItemParceJsonMissingField() throws {
        let json1: [String: Any] = [kText: "bla bla bla",
                              kImportance: "важная",
                                kDeadline: 333,
                                  kIsDone: false,
                               kCreationDate: 111,
                               kLastChangeDate: 222]
        let json2: [String: Any] = [kId: "1",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json3: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let item3 = TodoItem(id: "1",
                             text: "bla bla bla",
                             importance: .basic,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))
        let json4: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let item4 = TodoItem(id: "1",
                             text: "bla bla bla",
                             importance: .important,
                             deadLine: nil,
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222))
        let json5: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json6: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kLastChangeDate: 222]
        let json7: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111]
        let item7 = TodoItem(id: "1",
                             text: "bla bla bla",
                             importance: .important,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: nil)


        XCTAssertEqual(TodoItem.parse(json: json1), nil)    // id
        XCTAssertEqual(TodoItem.parse(json: json2), nil)    // text
        XCTAssertEqual(TodoItem.parse(json: json3), item3)  // importance
        XCTAssertEqual(TodoItem.parse(json: json4), item4)  // deadLine
        XCTAssertEqual(TodoItem.parse(json: json5), nil)    // isDone
        XCTAssertEqual(TodoItem.parse(json: json6), nil)    // creationDate
        XCTAssertEqual(TodoItem.parse(json: json7), item7)  // lastChangeDate
    }

    func testTodoItemParceJsonEmptyField() throws {
        let json1: [String: Any] = [kId: "",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json2: [String: Any] = [kId: "1",
                                  kText: "",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json3: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json4: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: "",
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json5: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: "",
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json6: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: "",
                             kLastChangeDate: 222]
        let json7: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: ""]



        XCTAssertEqual(TodoItem.parse(json: json1), nil)    // id
        XCTAssertEqual(TodoItem.parse(json: json2), nil)    // text
        XCTAssertEqual(TodoItem.parse(json: json3), nil)    // importance
        XCTAssertEqual(TodoItem.parse(json: json4), nil)    // deadLine
        XCTAssertEqual(TodoItem.parse(json: json5), nil)    // isDone
        XCTAssertEqual(TodoItem.parse(json: json6), nil)    // creationDate
        XCTAssertEqual(TodoItem.parse(json: json7), nil)    // lastChangeDate
        // Оно всё настолько одинаковое, что надо бы сюда цикл запилить...
    }

    func testTodoItemParceJsonIncorrectField() throws {
        let json1: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "ffa",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json2: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: "333",
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json3: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: "false",
                             kCreationDate: 111,
                             kLastChangeDate: 222]
        let json4: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: "111",
                             kLastChangeDate: 222]
        let json5: [String: Any] = [kId: "1",
                                  kText: "bla bla bla",
                            kImportance: "важная",
                              kDeadline: 333,
                                kIsDone: false,
                             kCreationDate: 111,
                             kLastChangeDate: "222"]

        XCTAssertEqual(TodoItem.parse(json: json1), nil)    // importance
        XCTAssertEqual(TodoItem.parse(json: json2), nil)    // deadLine
        XCTAssertEqual(TodoItem.parse(json: json3), nil)    // isDone
        XCTAssertEqual(TodoItem.parse(json: json4), nil)    // creationDate
        XCTAssertEqual(TodoItem.parse(json: json5), nil)    // lastChangeDate
    }
    
    // // MARK: - JSON Creation
    func testTodoItemCreateJson() throws {
        let sut = TodoItem(id: "1",
                           text: "bla bla bla",
                           importance: .important,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222))
        
        let item: [String: Any] = [kId: "1",
                                 kText: "bla bla bla",
                           kImportance: "важная",
                             kDeadline: 333,
                               kIsDone: false,
                            kCreationDate: 111,
                            kLastChangeDate: 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])[kId] as! String, item[kId] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kText] as! String, item[kText] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kImportance] as? String, item[kImportance] as? String)
        XCTAssertEqual((sut.json as! [String: Any])[kDeadline] as? Int, item[kDeadline] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])[kIsDone] as! Bool, item[kIsDone] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])[kCreationDate] as! Int, item[kCreationDate] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])[kLastChangeDate] as? Int, item[kLastChangeDate] as? Int)
    }
    // Importance
    func testTodoItemCreateJsonBasicImportance() throws {
        let sut = TodoItem(id: "1",
                           text: "bla bla bla",
                           importance: .basic,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222))
        
        let item: [String: Any] = [kId: "1",
                                 kText: "bla bla bla",
                             kDeadline: 333,
                               kIsDone: false,
                            kCreationDate: 111,
                            kLastChangeDate: 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])[kId] as! String, item[kId] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kText] as! String, item[kText] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kImportance] as? String, item[kImportance] as? String)
        XCTAssertEqual((sut.json as! [String: Any])[kDeadline] as? Int, item[kDeadline] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])[kIsDone] as! Bool, item[kIsDone] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])[kCreationDate] as! Int, item[kCreationDate] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])[kLastChangeDate] as? Int, item[kLastChangeDate] as? Int)
    }
    // DeadLine
    func testTodoItemCreateJsonMissingDeadLine() throws {
        let sut = TodoItem(id: "1",
                           text: "bla bla bla",
                           importance: .important,
                           deadLine: nil,
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: Date(timeIntervalSince1970: 222))
        
        let item: [String: Any] = [kId: "1",
                                 kText: "bla bla bla",
                           kImportance: "важная",
                               kIsDone: false,
                            kCreationDate: 111,
                            kLastChangeDate: 222]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])[kId] as! String, item[kId] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kText] as! String, item[kText] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kImportance] as? String, item[kImportance] as? String)
        XCTAssertEqual((sut.json as! [String: Any])[kDeadline] as? Int, item[kDeadline] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])[kIsDone] as! Bool, item[kIsDone] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])[kCreationDate] as! Int, item[kCreationDate] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])[kLastChangeDate] as? Int, item[kLastChangeDate] as? Int)
    }
    // LastChangeDate
    func testTodoItemCreateJsonMissingLastChangeDate() throws {
        let sut = TodoItem(id: "1",
                           text: "bla bla bla",
                           importance: .important,
                           deadLine: Date(timeIntervalSince1970: 333),
                           isDone: false,
                           creationDate: Date(timeIntervalSince1970: 111),
                           lastChangeDate: nil)
        
        let item: [String: Any] = [kId: "1",
                                 kText: "bla bla bla",
                           kImportance: "важная",
                             kDeadline: 333,
                               kIsDone: false,
                            kCreationDate: 111]
        
        XCTAssertEqual((sut.json as! [String: Any]).keys, item.keys)
        
        XCTAssertEqual((sut.json as! [String: Any])[kId] as! String, item[kId] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kText] as! String, item[kText] as! String)
        XCTAssertEqual((sut.json as! [String: Any])[kImportance] as? String, item[kImportance] as? String)
        XCTAssertEqual((sut.json as! [String: Any])[kDeadline] as? Int, item[kDeadline] as? Int)
        XCTAssertEqual((sut.json as! [String: Any])[kIsDone] as! Bool, item[kIsDone] as! Bool)
        XCTAssertEqual((sut.json as! [String: Any])[kCreationDate] as! Int, item[kCreationDate] as! Int)
        XCTAssertEqual((sut.json as! [String: Any])[kLastChangeDate] as? Int, item[kLastChangeDate] as? Int)
    }
}

//MARK: - Keys
// Keys that used in backend
private let kId = "id"
private let kText = "text"
private let kImportance = "importance"
private let kDeadline = "deadline"
private let kIsDone = "done"
private let kCreationDate = "created_at"
private let kLastChangeDate = "changed_at"
