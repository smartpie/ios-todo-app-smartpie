import UIKit

enum Status {
    case showAll
    case showUncompleted
}

class RootViewModel: UIViewController {

    var fileName = "TodoItems.json"
    var fileCache = FileCache()
    weak var viewController: RootViewController?

    var todoListState: [TodoItem] = []
    private(set) var status: Status = Status.showUncompleted

    init(fileName: String = "TodoItems.json",
         fileCache: FileCache = FileCache()){
        super.init(nibName: nil, bundle: nil)
        self.fileName = fileName
        self.fileCache = fileCache
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootViewModel {
    // MARK: - Main functions
    func fetchData(){
        do{
            try fileCache.loadTodosFromFile(fileNameJson: self.fileName)
            print(fileCache.todoItems)
        } catch {
            print("Some error while fetching data \(error)")
        }
    }

    func openTodoItem(_ todoItem: TodoItem = TodoItem(text: "")){
        let newNavViewController = UINavigationController(rootViewController: EditTodoItemViewController(todoItem))
        newNavViewController.modalTransitionStyle = .coverVertical
        newNavViewController.modalPresentationStyle = .formSheet
        viewController?.present(newNavViewController, animated: true)
    }

    func saveTodoItem(_ todoItem: TodoItem){
        do{
            self.fileCache.addTodoItem(todoItem)
            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            self.updateTodoListState()
        } catch {
            print("Some error while saving data: \(error)")
        }
    }

    func removeTodoItem(id: String){
        do{
            self.fileCache.removeTodoItemById(id)
            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            self.updateTodoListState()
        } catch {
            print("Some error while trying to delete todoItem and save changed data: \(error)")
        }
    }

    func switchIsDoneState(_ oldTodo: TodoItem){
        let newTodo = TodoItem(id: oldTodo.id,
                               text: oldTodo.text,
                               importance: oldTodo.importance,
                               deadLine: oldTodo.deadLine,
                               isDone: !oldTodo.isDone,
                               creationDate: oldTodo.creationDate,
                               lastChangeDate: oldTodo.lastChangeDate
        )
        self.saveTodoItem(newTodo)
    }

    //MARK: - TodoList Update
    func updateTodoListState(){
        switch status{
        case Status.showUncompleted:
            self.todoListState = self.fileCache.todoItems.filter( {!$0.isDone} )
        case Status.showAll:
            self.todoListState = self.fileCache.todoItems
        }
        self.viewController?.updateData()
    }

    func switchPresentationStatus() {
        switch self.status{
        case Status.showUncompleted:
            self.status = .showAll
        case Status.showAll:
            self.status = .showUncompleted
        }
    }
}
