import UIKit

@MainActor
class EditTodoItemViewModel {

    weak var viewController: EditTodoItemViewController?

    var todoItemState: TodoItem

    init(_ item: TodoItem) {
        self.todoItemState = item

        loadData()
    }
}

@MainActor
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
        if !todoItemState.text.isEmpty {
            viewController?.textView.text = todoItemState.text
            viewController?.textView.textColor = UIColor.labelPrimary
        }
        viewController?.currentImportance = todoItemState.importance
        if todoItemState.deadLine != nil {
            viewController?.deadLineSwitch.isOn = true
            viewController?.deadLineDateButton.setTitle(
                todoItemState.deadLine?.dateForLabel,
                for: .normal
            )
            viewController?.deadLineDateButton.isHidden = false
            viewController?.deadLineDateButton.alpha = 1
            viewController?.datePicker.date = todoItemState.deadLine ?? Date()
        }
        viewController?.currentDeadLine = todoItemState.deadLine
    }
}
