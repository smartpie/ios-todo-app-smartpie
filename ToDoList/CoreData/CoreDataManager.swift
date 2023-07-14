import UIKit
import CoreData

enum CDManagerErrors: Error {
    case entityDescriptionCreationFail
}

@MainActor
public final class CoreDataManager: NSObject {
    public static let shared = CoreDataManager()
    override private init() {}

    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }

    // MARK: - CRUD
    public func createTodo(_ todoItem: TodoItem) {
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

        appDelegate.saveContext()
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

    public func updateTodo(_ todoItem: TodoItem) {
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

        appDelegate.saveContext()
    }

    public func deleteTodoList() {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        do {
            let results = try context.fetch(fetchRequest) as [TodoItemCD]
            results.forEach { context.delete($0) }
        } catch {
            print("CoreData – Error while trying to wipe out TodoList")
        }

        appDelegate.saveContext()
    }

    public func deleteTodo(id: String) {
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")

        guard let results = try? context.fetch(fetchRequest) as [TodoItemCD],
              let todo = results.first(where: { $0.id == id }) else {
            print("CoreData – Unable to find element with id:\(id) to delete it")
            return
        }

        context.delete(todo)

        appDelegate.saveContext()
    }

    // MARK: - Private functions
    private func CDItemToRegularItem(_ cdItem: TodoItemCD) -> TodoItem {
        return TodoItem(id: cdItem.id ?? UUID().uuidString,
                        text: cdItem.text ?? "Unknown",
                        importance: Importance(rawValue: cdItem.importance ?? "basic") ?? .basic,
                        deadLine: cdItem.deadline,
                        isDone: cdItem.done,
                        creationDate: cdItem.created_at ?? Date(),
                        lastChangeDate: cdItem.changed_at)
    }
}
