import UIKit

var rootViewModel: RootViewModel = RootViewModel()

class RootViewController: UIViewController {
    private lazy var addTodoItemButton = UIButton(type: .system)
    private var addTodoItemButtonXconstraint: NSLayoutConstraint?
    private var addTodoItemButtonYconstraint: NSLayoutConstraint?

    private lazy var tableView = UITableView.init(frame: .zero, style: UITableView.Style.insetGrouped)
    private let tableHeaderView = TableViewHeader()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backPrimary

        setupNavigation()
        setupTableView()
        setupAddTodoItemButton()

        // connect rootViewModel
        rootViewModel.viewController = self
        rootViewModel.fetchData()
        rootViewModel.updateTodoListState()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        setupConstraintForAddTodoItemButton()
    }

    // MARK: - Navigation
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Мои дела"
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 0)
    }

    // MARK: - AddButton
    private func setupAddTodoItemButton() {
        addTodoItemButton.translatesAutoresizingMaskIntoConstraints = false


        addTodoItemButton.addTarget(self, action: #selector(openTodoItemEditor), for: .touchUpInside)
        let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.colorWhite, UIColor.colorBlue])
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 35).applying(colorsConfig)
        let icon = UIImage(systemName: "plus.circle.fill", withConfiguration: iconConfig)
        addTodoItemButton.setImage(icon, for: .normal)
        addTodoItemButton.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        addTodoItemButton.layer.shadowColor = CGColor(red: 0, green: 49/255, blue: 102/255, alpha: 0.3)
        addTodoItemButton.layer.shadowOpacity = 1
        addTodoItemButton.layer.shadowRadius = 20

        view.addSubview(addTodoItemButton)

        setupConstraintForAddTodoItemButton()
    }

    private func setupConstraintForAddTodoItemButton() {
        addTodoItemButtonXconstraint?.isActive = false
        addTodoItemButtonYconstraint?.isActive = false

        if UIDevice.current.orientation.isLandscape {
            addTodoItemButtonXconstraint = addTodoItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
            addTodoItemButtonYconstraint = addTodoItemButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        } else {
            addTodoItemButtonXconstraint = addTodoItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            addTodoItemButtonYconstraint = addTodoItemButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        }

        addTodoItemButtonXconstraint?.isActive = true
        addTodoItemButtonYconstraint?.isActive = true
    }

    @objc func openTodoItemEditor() {
        rootViewModel.openTodoItem()
    }

    // MARK: - TableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = UIColor.backPrimary
        tableView.register(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: TableViewHeader.identifier)
        tableView.register(CellView.self, forCellReuseIdentifier: CellView.identifier)
        tableView.register(AddCellView.self, forCellReuseIdentifier: AddCellView.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}


extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootViewModel.todoListState.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == rootViewModel.todoListState.count {
            let newCell = tableView.dequeueReusableCell(withIdentifier: AddCellView.identifier, for: indexPath)
            guard
                let newCell = newCell as? AddCellView
            else { return UITableViewCell() }
            newCell.addCellTapped = { [weak self] in self?.AddCellTapped() }
            newCell.selectionStyle = .none
            return newCell
        } else {
            let customCell = tableView.dequeueReusableCell(withIdentifier: CellView.identifier, for: indexPath)
            guard
                let customCell = customCell as? CellView
            else { return UITableViewCell() }
            let todoList = filterTodoList(list: rootViewModel.todoListState)
            let item = todoList[indexPath.row]
            customCell.configureCell(item)
            customCell.valueDidChange = { rootViewModel.switchIsDoneState(item) }
            customCell.selectionStyle = .none
            return customCell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableHeaderView.textView.text = "Выполнено - \(rootViewModel.fileCache.todoItems.filter{$0.isDone }.count)"
        tableHeaderView.valueDidChange = { rootViewModel.updateTodoListState() }
        return tableHeaderView
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
       if indexPath.row == rootViewModel.todoListState.count {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            tableView.cellForRow(at: indexPath) is CellView
        else { return }
        let item = rootViewModel.todoListState[indexPath.row]
        rootViewModel.openTodoItem(item)
    }

    // Table Corner Radius     *CostilMagic*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 16, height: 16))

            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else if indexPath.row == rootViewModel.todoListState.count {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 16, height: 16))

            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 0, height: 0))

            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
    }

    func updateData(){
        tableView.reloadData()
    }

    func filterTodoList(list: [TodoItem]) -> ([TodoItem]){
        if rootViewModel.status == Status.showAll{
            return rootViewModel.fileCache.todoItems
        } else {
            return rootViewModel.fileCache.todoItems.filter( {!$0.isDone} )
        }
    }

    @objc func AddCellTapped(){
        rootViewModel.openTodoItem()
    }
}
