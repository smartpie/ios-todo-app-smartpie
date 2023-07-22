import Foundation
import CoreData

@objc(TodoItemCD)
public class TodoItemCD: NSManagedObject {}

extension TodoItemCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCD> {
        return NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")
    }

    @NSManaged public var changed_at: Date?
    @NSManaged public var created_at: Date
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var id: String
    @NSManaged public var importance: String
    @NSManaged public var last_updated_by: String?
    @NSManaged public var text: String

}

extension TodoItemCD : Identifiable {

}
