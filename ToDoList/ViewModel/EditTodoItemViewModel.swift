import UIKit

class EditTodoItemViewModel {

    weak var viewController: EditTodoItemViewController?

    var todoItem: TodoItem?
    var todoItemState: TodoItem

    init(_ item: TodoItem) {
        self.todoItem = item
        self.todoItemState = item

        loadData()
    }
}

extension EditTodoItemViewModel {

    func saveItem(_ item: TodoItem){
        rootViewModel.saveTodoItem(item)
        viewController?.dismiss(animated: true)
    }

    func deleteItem(id: String) {
        rootViewModel.removeTodoItem(id: id)
        viewController?.dismiss(animated: true)
    }

    func loadData() {
        if !todoItemState.text.isEmpty{
            viewController?.textView.text = todoItemState.text
            viewController?.textView.textColor = UIColor.labelPrimary
        }
        viewController?.currentImportance = todoItemState.importance
        viewController?.currentDeadline = todoItemState.deadLine
    }
}
