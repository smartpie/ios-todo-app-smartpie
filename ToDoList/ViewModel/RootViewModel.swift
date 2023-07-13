import UIKit
import Foundation

enum Status {
    case showAll
    case showUncompleted
}

class RootViewModel: UIViewController {

    var fileName = "TodoItems.json"
    let networkingService = DefaultNetworkingService(deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
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
            // JSON
//            try self.fileCache.loadTodosFromFile(fileNameJson: self.fileName)
            // CoreData
            let todoList = CoreDataManager.shared.fetchTodoList()
            for item in todoList {
                self.fileCache.addTodoItem(item)
            }
            // SQLite
            // coming soon...
        } catch {
            print("Some error while fetching data \(error)")
        }

        if fileCache.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            loadTodoList()
        }
    }

    func openTodoItem(_ todoItem: TodoItem = TodoItem(text: "")){
        let newNavViewController = UINavigationController(rootViewController: EditTodoItemViewController(todoItem))
        newNavViewController.modalTransitionStyle = .coverVertical
        newNavViewController.modalPresentationStyle = .formSheet
        viewController?.present(newNavViewController, animated: true)
    }

    func saveTodoItem(_ todoItem: TodoItem, _ isNew: Bool = false){
        do{
            self.fileCache.addTodoItem(todoItem)
            // JSON
//            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            // CoreData
            if isNew {
                CoreDataManager.shared.createTodo(todoItem)
            } else {
                CoreDataManager.shared.updateTodo(todoItem)
            }
            // SQLite
            // coming soon...
            self.updateTodoListState()
        } catch {
            print("Some error while saving data: \(error)")
        }

        if fileCache.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            updateTodoItem(todoItem, isNew)
        }
    }

    func removeTodoItem(id: String){
        do {
            self.fileCache.removeTodoItemById(id)
            // JSON
//            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            // CoreData
            CoreDataManager.shared.deleteTodo(id: id)
            // SQLite
            // coming soon...
            self.updateTodoListState()
        } catch {
            print("Some error while trying to delete todoItem and save changed data: \(error)")
        }

        if fileCache.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            deleteTodoItem(id)
        }
    }

    func deleteRow(at indexPath: IndexPath){
        let id = self.todoListState[indexPath.row].id
        do {
            self.fileCache.removeTodoItemById(id)
            // JSON
//            try self.fileCache.saveTodosToFile(fileNameJson: rootViewModel.fileName)
            // CoreData
            CoreDataManager.shared.deleteTodo(id: id)
            // SQLite
            // coming soon...
            self.todoListState.remove(at: indexPath.row)
            self.viewController?.deleteRow(at: indexPath)
        } catch {
            print("Error: deleteRow()")
        }

        if fileCache.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            deleteTodoItem(id)
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
    func updateTodoListState() {
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

    //MARK: - Networking
    private func syncTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let todoList = try await networkingService.patchList(todoItems: self.fileCache.todoItems)
                self.fileCache.removeAllTodoItems()
                for item in todoList {
                    self.fileCache.addTodoItem(item)
                }
                // JSON
//                try self.fileCache.saveTodosToFile(fileNameJson: self.fileName)
                // CoreData
                CoreDataManager.shared.deleteTodoList()
                for item in todoList {
                    CoreDataManager.shared.createTodo(item)
                }
                // SQLite
                // coming soon...
                self.fileCache.isDirty = false

                updateTodoListState()
            } catch {
                print("Error while syncing data from sever")
            }
        }
    }

    private func loadTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let todoList = try await networkingService.getList()
                self.fileCache.removeAllTodoItems()
                for item in todoList {
                    self.fileCache.addTodoItem(item)
                }
                // JSON
//                try self.fileCache.saveTodosToFile(fileNameJson: self.fileName)
                // CoreData
                CoreDataManager.shared.deleteTodoList()
                for item in todoList {
                    CoreDataManager.shared.createTodo(item)
                }
                // SQLite
                // coming soon...
                updateTodoListState()
            } catch {
                print("Error while loading data from sever")
            }
        }
    }
    
    private func updateTodoItem(_ todoItem: TodoItem,_ isNew: Bool) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                if isNew {
                    try await networkingService.postItem(todoItem: todoItem)
                } else {
                    try await networkingService.putItem(todoItem: todoItem)
                }
            } catch {
                self.fileCache.isDirty = true
                print("Error while updating TodoItem on server")
            }
        }
    }

    private func deleteTodoItem(_ id: String) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                try await networkingService.deleteItemById(id: id)
            } catch {
                self.fileCache.isDirty = true
                print("Error while deleting TodoItem from server")
            }
        }
    }
}
