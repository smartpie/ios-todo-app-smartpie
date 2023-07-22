import UIKit
import CoreData

enum CDManagerErrors: Error {
    case entityDescriptionCreationFail
}

@MainActor
struct CoreDataManager {
    static let shared = CoreDataManager()

    private var context: NSManagedObjectContext {
        CoreDataManager.shared.container.viewContext
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoListSwiftUI")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }


    // MARK: - CRUD
    public func createTodo(_ todoItem: TodoItem) throws {
        guard let todoEntityDescription = NSEntityDescription.entity(forEntityName: "TodoItemCD", in: context) else {
            print("CoreData – Error while creating context")
            return
        }
        let todo = TodoItemCD(entity: todoEntityDescription, insertInto: context)

        todo.id = todoItem.id
        todo.text = todoItem.text
        todo.importance = todoItem.importance.rawValue
        todo.done = todoItem.isDone
        todo.last_updated_by = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        todo.deadline = todoItem.deadLine
        todo.changed_at = todoItem.lastChangeDate
        todo.created_at = todoItem.creationDate

        try context.save()
    }

    public func fetchTodoList() -> [TodoItem] {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        do {
            let results = (try context.fetch(fetchRequest) as [TodoItemCD]).map {
                CDItemToRegularItem($0)
            }
            return results
        } catch {
            print("CoreData – Error while fetching")
        }

        return []
    }

    public func updateTodo(_ todoItem: TodoItem) throws {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        guard let results = try? context.fetch(fetchRequest) as [TodoItemCD],
              let todo = results.first(where: { $0.id == todoItem.id }) else {
            print("CoreData – Unable to find element with id:\(todoItem.id) to update it")
            return
        }

        todo.text = todoItem.text
        todo.importance = todoItem.importance.rawValue
        todo.done = todoItem.isDone
        todo.last_updated_by = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        todo.deadline = todoItem.deadLine
        todo.changed_at = todoItem.lastChangeDate
        todo.created_at = todoItem.creationDate

        try context.save()
    }

    public func deleteTodoList() throws {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        do {
            let results = try context.fetch(fetchRequest) as [TodoItemCD]
            results.forEach { context.delete($0) }
        } catch {
            print("CoreData – Error while trying to wipe out TodoList")
        }

        try context.save()
    }

    public func deleteTodo(id: String) throws {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        guard let results = try? context.fetch(fetchRequest) as [TodoItemCD],
              let todo = results.first(where: { $0.id == id }) else {
            print("CoreData – Unable to find element with id:\(id) to delete it")
            return
        }

        context.delete(todo)

        try context.save()
    }

    // MARK: - Private functions
    private func CDItemToRegularItem(_ cdItem: TodoItemCD) -> TodoItem {
        return TodoItem(id: cdItem.id,
                        text: cdItem.text,
                        importance: Importance(rawValue: cdItem.importance) ?? .basic,
                        deadLine: cdItem.deadline,
                        isDone: cdItem.done,
                        creationDate: cdItem.created_at,
                        lastChangeDate: cdItem.changed_at)
    }
}
