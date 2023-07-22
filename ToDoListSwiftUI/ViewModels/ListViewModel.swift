import Foundation
import UIKit

@MainActor
class ListViewModel: ObservableObject {
    static let shared = ListViewModel()

    @Published var items: [TodoItem] = []
    static let networkingService = DefaultNetworkingService(deviceID: UIDevice.current.identifierForVendor!.uuidString)

    static var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }

    // MARK: - CRUD
    public func fetch() {
        items = CoreDataManager.shared.fetchTodoList()

        if ListViewModel.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            loadTodoList()
        }
    }

    public func createTodoItem(item: TodoItem) throws {
        try CoreDataManager.shared.createTodo(item)

        if ListViewModel.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            upsertTodoItem(item, true)
        }
    }

    public func updateTodoItem(item: TodoItem) throws {
        try CoreDataManager.shared.updateTodo(item)

        if ListViewModel.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            upsertTodoItem(item, false)
        }
    }

    public func deleteTodoItem(item: TodoItem) throws {
        try CoreDataManager.shared.deleteTodo(id: item.id)

        if ListViewModel.isDirty {
            print("Dirty")
            syncTodoList()
        } else {
            print("Not Dirty")
            deleteTodoItem(item.id)
        }
    }

    // MARK: - Support Functions
    public func switchIsDone(item: TodoItem) {
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[itemIndex] = TodoItem(id: items[itemIndex].id,
                                        text: items[itemIndex].text,
                                        importance: items[itemIndex].importance,
                                        deadLine: items[itemIndex].deadLine,
                                        isDone: !items[itemIndex].isDone,
                                        creationDate: items[itemIndex].creationDate,
                                        lastChangeDate: items[itemIndex].lastChangeDate)

            do {
                try updateTodoItem(item: items[itemIndex])
            } catch {
                print("Мама дорогая, мы в перде")
            }
        }
    }

    // MARK: - Networking CRUD
    private func syncTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                items = try await ListViewModel.networkingService.patchList(todoItems: items)

                try CoreDataManager.shared.deleteTodoList()
                for item in items {
                    try CoreDataManager.shared.createTodo(item)
                }

                ListViewModel.isDirty = false
            } catch {
                print("Error while loading data from sever")
            }
        }
    }

    private func loadTodoList() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                items = try await ListViewModel.networkingService.getList()

                try CoreDataManager.shared.deleteTodoList()
                for item in items {
                    try CoreDataManager.shared.createTodo(item)
                }
            } catch {
                ListViewModel.isDirty = true
                print("Error while loading data from sever")
            }
        }
    }

    private func upsertTodoItem(_ todoItem: TodoItem, _ isNew: Bool) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                if isNew {
                    try await ListViewModel.networkingService.postItem(todoItem: todoItem)
                } else {
                    try await ListViewModel.networkingService.putItem(todoItem: todoItem)
                }
            } catch {
                ListViewModel.isDirty = true
                print("Error while updating TodoItem on server")
            }
        }
    }

    private func deleteTodoItem(_ id: String) {
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                try await ListViewModel.networkingService.deleteItemById(id: id)
            } catch {
                ListViewModel.isDirty = true
                print("Error while deleting TodoItem from server")
            }
        }
    }
}
