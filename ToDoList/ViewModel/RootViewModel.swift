import UIKit
import Foundation

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
    func fetchData() {
        do {
            try self.fileCache.loadTodosFromFile(fileNameJson: self.fileName)
        } catch {
            print("Some error while fetching data \(error)")
        }

        let taska = Task(priority: .background) { [weak self] in
            guard let self = self else { return }
            do {
                let net = DefaultNetworkingService()
                let nothing = try await net.getList()
                
            } catch {
                print("Some Error")
            }
        }

//        taska.cancel()
        // Если раскомментить, то такска кэенсельнётся(удивительно) и оно даст ошибку в консоль
        // Также ошибка будет, если сервер ошибку выдаст, правда тогда мы код ответа сервера ещё в консольке увидим
    }

    func openTodoItem(_ todoItem: TodoItem = TodoItem(text: "")){
        let newNavViewController = UINavigationController(rootViewController: EditTodoItemViewController(todoItem))
        newNavViewController.modalTransitionStyle = .coverVertical
        newNavViewController.modalPresentationStyle = .formSheet
        viewController?.present(newNavViewController, animated: true)
    }

    func saveTodoItem(_ todoItem: TodoItem){
        DispatchQueue.main.async {
            do{
                self.fileCache.addTodoItem(todoItem)
                try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
                self.updateTodoListState()
            } catch {
                print("Some error while saving data: \(error)")
            }
        }
    }

    func removeTodoItem(id: String){
        DispatchQueue.main.async {
            do{
                self.fileCache.removeTodoItemById(id)
                try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
                self.updateTodoListState()
            } catch {
                print("Some error while trying to delete todoItem and save changed data: \(error)")
            }
        }
    }

    func deleteRow(at indexPath: IndexPath){
        let id = self.todoListState[indexPath.row].id
        do{
            self.fileCache.removeTodoItemById(id)
            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            self.todoListState.remove(at: indexPath.row)
            self.viewController?.deleteRow(at: indexPath)
        } catch {
            print("Error: deleteToDo()")
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

    func switchIsDoneStateSwipe(_ oldTodo: TodoItem, _ indexPath: IndexPath) {
        switchIsDoneState(oldTodo)
        self.viewController?.reloadRow(at: indexPath)
    }

    //MARK: - TodoList Update
    func updateTodoListState(){
        switch status{
        case Status.showUncompleted:
            self.todoListState = self.fileCache.todoItems.filter( {!$0.isDone} )
        case Status.showAll:
            self.todoListState = self.fileCache.todoItems
        }
        self.viewController?.reloadData()
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
