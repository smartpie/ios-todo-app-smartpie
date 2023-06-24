import UIKit

class EditTodoItemViewController: UIViewController {
    let handler: TodoListHandler

    init(handler: TodoListHandler) {
        self.handler = handler
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: TodoItem Properties
    private var currentText = ""
    private var currentImportance = Importance.basic
    private var currentDeadline: Date? = nil
    var todoItem: TodoItem? = nil


// MARK: Views
    private lazy var scrollView = UIScrollView()
    private lazy var wrapperView = UIView()

    private lazy var textView = UITextView()

    private lazy var importanceLabel = UILabel()
    private lazy var importanceControl = UISegmentedControl()
    private lazy var importanceView = UIView()
    private let firstSeparatorView = SeparatorView()
    private lazy var deadLineLabel = UILabel()
    private lazy var deadLineDateButton = UIButton()
    private lazy var deadLineStackView = UIStackView()
    private lazy var deadLineSwitch = UISwitch()
    private lazy var deadLineView = UIView()
    private let secondSeparatorView = SeparatorView()
    private lazy var datePicker = UIDatePicker()

    private lazy var detailsStackView = UIStackView()
    
    private lazy var deleteButton = UIButton()

// MARK: State variables
    private var wasDatePickerToggled = false
    private var isDatePickerToggled = false

// MARK: LifeCycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        super.loadView()

        if let todoItem = handler.todoItem {
            currentText = todoItem.text
            currentImportance = todoItem.importance
            currentDeadline = todoItem.deadLine
            deleteButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            deleteButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Back.Primary")

        setupNavigationItem()

        setupMainView()
        constructMainView()
        constructMainViewConstraints()

        registerKeyboardNotifications()
        addTapGestureRecognizerToDismissKeyboard()

        if let todoItem = handler.todoItem {
            if todoItem.deadLine != nil {
                deadLineSwitch.isOn = true
                deadLineDateButton.setTitle(
                    todoItem.deadLine?.dateForLabel,
                    for: .normal
                )
                deadLineDateButton.isHidden = false
                deadLineDateButton.alpha = 1
                datePicker.date = todoItem.deadLine ?? Date()
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

// MARK: - UI Setup
    private func setupMainView() {
        setupScrollView()
        setupWrapperView()
        setupTextView()

        setupImportanceLabel()
        setupImportanceControl()
        setupImportanceView()
        setupFirstSeparatorView()
        setupDeadLineLabel()
        setupDeadLineDateButton()
        setupDeadLineStackView()
        setupDeadLineSwitch()
        setupDeadLineView()
        setupSecondSeparatorView()
        setupDatePicker()

        setupDetailsStackView()

        setupDeleteButton()
    }

    private func setupNavigationItem() {
        navigationItem.title = "Дело"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(didTapCancelButton)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(didTapSaveButton)
        )

//        navigationItem.rightBarButtonItem?.isEnabled = false
        checkTodoItem()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = wrapperView.bounds.size
        scrollView.keyboardDismissMode = .interactive
    }

    private func setupWrapperView() {
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(named: "Back.Secondary")
        textView.layer.cornerRadius = 16
        textView.font = .systemFont(ofSize: 17, weight: .regular)

        if currentText == "" {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor(named: "Label.Tertiary")
        } else {
            textView.text = currentText
            textView.textColor = UIColor(named: "Label.Primary")
        }

        textView.textContainerInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 12,
            right: 16
        )

        textView.delegate = self
    }

    private func setupImportanceLabel() {
        importanceLabel.translatesAutoresizingMaskIntoConstraints = false

        importanceLabel.text = "Важность"
        importanceLabel.font = UIFont.Body
    }

    private func setupImportanceControl() {
        importanceControl.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(scale: .small).applying(UIImage.SymbolConfiguration(weight: .bold))
        let arrowImage = UIImage(systemName: "arrow.down", withConfiguration: configuration)?
            .withTintColor(UIColor(named: "Color.Gray") ?? .gray, renderingMode: .alwaysOriginal)
        let exclamationmarkImage = UIImage(systemName: "exclamationmark.2", withConfiguration: configuration)?
            .withTintColor(UIColor(named: "Color.Red") ?? .red, renderingMode: .alwaysOriginal)

        importanceControl.insertSegment(with: arrowImage, at: 0, animated: true)
        importanceControl.insertSegment(withTitle: "нет", at: 1, animated: true)
        importanceControl.insertSegment(with: exclamationmarkImage, at: 2, animated: true)

        switch currentImportance {
        case .important:
            importanceControl.selectedSegmentIndex = 2
        case .basic:
            importanceControl.selectedSegmentIndex = 1
        case .low:
            importanceControl.selectedSegmentIndex = 0
        }

        importanceControl.addTarget(
            self,
            action: #selector(didSelectImportance),
            for: .valueChanged
        )
    }

    private func setupImportanceView() {
        importanceView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupFirstSeparatorView() {}

    private func setupDeadLineLabel() {
        deadLineLabel.translatesAutoresizingMaskIntoConstraints = false

        deadLineLabel.text = "Сделать до"
        deadLineLabel.font = UIFont.Body
    }

    private func setupDeadLineDateButton() {
        deadLineDateButton.translatesAutoresizingMaskIntoConstraints = false

        deadLineDateButton.setTitle("Тут появится дата", for: .normal)
        deadLineDateButton.setTitleColor(UIColor(named: "Color.Blue"), for: .normal)
        deadLineDateButton.tintColor = UIColor(named: "Color.Blue")
        deadLineDateButton.titleLabel?.font = UIFont.Footnote
        deadLineDateButton.addTarget(
            self,
            action: #selector(toggleDatePicker),
            for: .touchUpInside
        )
        deadLineDateButton.isHidden = true
        deadLineDateButton.alpha = 0
    }

    private func setupDeadLineStackView() {
        deadLineStackView.translatesAutoresizingMaskIntoConstraints = false

        deadLineStackView.axis = .vertical
        deadLineStackView.distribution = .equalCentering
        deadLineStackView.alignment = .leading
    }

    private func setupDeadLineSwitch() {
        deadLineSwitch.translatesAutoresizingMaskIntoConstraints = false

        deadLineSwitch.addTarget(self, action: #selector(toggleDeadLine), for: .valueChanged)
    }

    private func setupDeadLineView() {
        deadLineView.translatesAutoresizingMaskIntoConstraints = false
        deadLineView.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }

    private func setupSecondSeparatorView() {
        secondSeparatorView.isHidden = true
    }

    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .orange
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = .current
        datePicker.calendar.firstWeekday = 2
        datePicker.isHidden = true
        datePicker.minimumDate = Calendar.current.startOfDay(for: Date())

//        defaultConfigureDatePicker()
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
    }

    private func defaultConfigureDatePicker() {
        let calendar = Calendar.current
        datePicker.minimumDate = calendar.startOfDay(for: Date())
        let selectedDate = Date()
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            datePicker.date = nextDay
            deadLineDateButton.setTitle(nextDay.dateForLabel, for: .normal)
            currentDeadline = nextDay
        }
    }


    private func setupDetailsStackView() {
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.axis = .vertical
        detailsStackView.distribution = .fill
        detailsStackView.layer.cornerRadius = 16
        detailsStackView.backgroundColor = UIColor(named: "Back.Secondary")
    }

    private func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.backgroundColor = UIColor(named: "Back.Secondary")
        deleteButton.setTitleColor(UIColor(named: "Color.Red"), for: .normal)
        deleteButton.setTitleColor(UIColor(named: "Label.Tertiary"), for: .disabled)
        deleteButton.layer.cornerRadius = 16
        deleteButton.titleLabel?.font = UIFont.Body
        deleteButton.setTitle("Удалить", for: .normal)

        deleteButton.addTarget(
            self,
            action: #selector(deleteTodoItem),
            for: .touchUpInside
        )

//        deleteButton.isEnabled = (todoItem == nil) ? false : true
    }

// MARK: - UI Construction
    private func constructMainView() {
        view.addSubview(scrollView)

        scrollView.addSubview(wrapperView)

        wrapperView.addSubview(textView)

        importanceView.addSubview(importanceLabel)
        importanceView.addSubview(importanceControl)

        deadLineStackView.addArrangedSubview(deadLineLabel)
        deadLineStackView.addArrangedSubview(deadLineDateButton)
        deadLineView.addSubview(deadLineStackView)
        deadLineView.addSubview(deadLineSwitch)

        [importanceView, firstSeparatorView, deadLineView, secondSeparatorView, datePicker].map {
            detailsStackView.addArrangedSubview($0)
        }

        wrapperView.addSubview(detailsStackView)
        wrapperView.addSubview(deleteButton)
    }

/*
 scrollView
     └── wrapperView
         ├── textView
         ├── detailsStackView
         │   ├── importanceView
         │   │   ├── importanceLabel
         │   │   └── importanceControl
         │   ├── firstSeparator
         │   ├── deadLineView
         │   │   ├── deadLineStackView
         │   │   │   ├── deadLineLabel
         │   │   │   └── deadLineButton
         │   │   └── deadLineSwitch
         │   ├── secondSeparator
         │   └── DatePicker
         └── deleteButton
 */

// MARK: - UI Constraints
    private func constructMainViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            wrapperView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),

            textView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            importanceLabel.leadingAnchor.constraint(equalTo: importanceView.leadingAnchor, constant: 16),
            importanceLabel.centerYAnchor.constraint(equalTo: importanceView.centerYAnchor),

            importanceControl.trailingAnchor.constraint(equalTo: importanceView.trailingAnchor, constant: -12),
            importanceControl.centerYAnchor.constraint(equalTo: importanceView.centerYAnchor),
            importanceControl.widthAnchor.constraint(equalToConstant: 150),

            importanceView.heightAnchor.constraint(equalToConstant: 56),
            importanceView.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor),

            firstSeparatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            // Не смог понять, почему но вот на эти выделенные справа констраинты оно ругается, но при этом они полностью работают
//            firstSeparatorView.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor, constant: 16),     // беды
//            firstSeparatorView.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor, constant: -16),  // беды

            deadLineStackView.leadingAnchor.constraint(equalTo: deadLineView.leadingAnchor, constant: 16),
            deadLineStackView.centerYAnchor.constraint(equalTo: deadLineView.centerYAnchor),

            deadLineLabel.heightAnchor.constraint(equalToConstant: 22),

            deadLineDateButton.heightAnchor.constraint(equalToConstant: 18),

            deadLineSwitch.trailingAnchor.constraint(equalTo: deadLineView.trailingAnchor, constant: -12),
            deadLineSwitch.centerYAnchor.constraint(equalTo: deadLineView.centerYAnchor),

            deadLineView.heightAnchor.constraint(equalToConstant: 56),
            deadLineView.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor),

            secondSeparatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
//            secondSeparatorView.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor, constant: 16),    // беды
//            secondSeparatorView.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor, constant: -16), // беды

            detailsStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            detailsStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),

            deleteButton.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            deleteButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 56),
            deleteButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),

//            datePicker.leadingAnchor.constraint(equalTo: detailsStackView.leadingAnchor, constant: 12),     // беды
//            datePicker.trailingAnchor.constraint(equalTo: detailsStackView.trailingAnchor, constant: -12),  // беды
        ])
    }

// MARK: - Actions
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapSaveButton() {
        view.endEditing(true)

        if let oldTodoItem = handler.todoItem {
            let newTodoItem = TodoItem(id: oldTodoItem.id,
                                    text: currentText,
                                    importance: currentImportance,
                                    deadLine: currentDeadline,
                                    isDone: oldTodoItem.isDone,
                                    creationDate: oldTodoItem.creationDate,
                                    lastChangeDate: oldTodoItem.lastChangeDate)
            self.todoItem = newTodoItem
            handler.addItem(newTodoItem)
        } else {
            let newTodoItem = TodoItem(text: currentText, importance: currentImportance, deadLine: currentDeadline)
            self.todoItem = newTodoItem
            handler.addItem(newTodoItem)
        }

        dismiss(animated: true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        textView.endEditing(true)
    }

    @objc private func datePickerValueChanged() {
        dismissKeyboard()
        deadLineDateButton.setTitle(datePicker.date.dateForLabel, for: .normal)
        currentDeadline = datePicker.date

        if !textView.text.isEmpty && textView.textColor != UIColor(named: "Label.Tertiary") {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    @objc private func toggleDatePicker() {
        dismissKeyboard()
        isDatePickerToggled.toggle()
        updateDatePickerView()
    }

    @objc private func toggleDeadLine() {
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let self = self else { return }

            deadLineDateButton.alpha = deadLineSwitch.isOn ? 1 : 0
            deadLineDateButton.isHidden = deadLineSwitch.isOn ? false : true

            view.layoutIfNeeded()
        })

        if isDatePickerToggled {
            UIView.animate(withDuration: 0.33, animations: { [weak self] in
                guard let self = self else { return }

                wasDatePickerToggled = true
                isDatePickerToggled = false
                secondSeparatorView.isHidden = true
                datePicker.isHidden = true
                defaultConfigureDatePicker()


                view.layoutIfNeeded()
            })
        } else if wasDatePickerToggled == true && deadLineSwitch.isOn {
            isDatePickerToggled = true
            updateDatePickerView()
        } else {
            wasDatePickerToggled = false
        }

        if deadLineSwitch.isOn == false {
            currentDeadline = nil
        } else {
            defaultConfigureDatePicker()
        }

        if !textView.text.isEmpty && textView.textColor != UIColor(named: "Label.Tertiary") {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    private func updateDatePickerView() {
        UIView.animate(withDuration: 0.33, animations: { [weak self] in
            guard let self = self else { return }

            secondSeparatorView.isHidden = !self.isDatePickerToggled
            datePicker.isHidden = !self.isDatePickerToggled

            view.layoutIfNeeded()
        })
    }

    @objc private func deleteTodoItem() {
        handler.deleteItem()
        todoItem = nil
        checkTodoItem()

        dismiss(animated: true)
    }

    @objc private func didSelectImportance() {
        switch importanceControl.selectedSegmentIndex {
        case 0:
            currentImportance = .low
        case 2:
            currentImportance = .important
        default:
            currentImportance = .basic
        }

        if !textView.text.isEmpty && textView.textColor != UIColor(named: "Label.Tertiary") {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

// MARK: - Tools
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func addTapGestureRecognizerToDismissKeyboard() {
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
//        detailsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        [importanceView, deadLineView].map {    // Как эту функцию вообще нормально сделать?
                                                // У меня клава выключается ток от свайпа де факто
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        }
    }

    private func checkTodoItem() {
        if todoItem != nil && currentText != "" {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}



extension EditTodoItemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: "Label.Tertiary") {
            textView.text = nil
            textView.textColor = UIColor(named: "Label.Primary")
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor(named: "Label.Tertiary")
        } else {
            currentText = textView.text
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.isEmpty ? false : true
    }
}

