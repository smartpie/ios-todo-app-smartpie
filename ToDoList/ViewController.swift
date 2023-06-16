import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // –––––––––––––––––– Checking the FileCache class ––––––––––––––––––
        let fileCache = FileCache()
        
        let item1 = TodoItem(id: "1",
                             importance: .important,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: nil,
                             text: "bla bla bla")
        
        let item2 = TodoItem(id: "2",
                             importance: .low,
                             deadLine: nil,
                             isDone: false,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222),
                             text: "bla bla bla")
        
        let item3 = TodoItem(id: "3",
                             importance: .basic,
                             deadLine: Date(timeIntervalSince1970: 333),
                             isDone: true,
                             creationDate: Date(timeIntervalSince1970: 111),
                             lastChangeDate: Date(timeIntervalSince1970: 222),
                             text: "bla bla bla")
        
        fileCache.addTodoItem(item1)
        fileCache.addTodoItem(item2)
        fileCache.addTodoItem(item3)
        

        fileCache.saveTodosToFile(fileNameJson: "test1.json")
        print("Saved JSON")
        
        
        let newCache = FileCache()
        newCache.loadTodosFromFile(fileNameJson: "test1.json")
        print("Loaded JSON")
        
        newCache.saveTodosToFile(fileNameCsv: "test2.csv")
        print("Saved CSV")
        
        fileCache.loadTodosFromFile(fileNameCsv: "test1.csv")
        print("Loaded CSV")

        print(fileCache.TodoItems)
    }


}

