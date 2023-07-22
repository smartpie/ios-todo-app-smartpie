import Foundation

protocol NetworkingService {
    func getList() async throws -> [TodoItem]
    func patchList(todoItems: [TodoItem]) async throws -> [TodoItem]
    func getItemById(id: String) async throws -> TodoItem?
    @discardableResult func postItem(todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func putItem(todoItem: TodoItem) async throws -> TodoItem?
    @discardableResult func deleteItemById(id: String) async throws -> TodoItem?
}
