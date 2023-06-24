import UIKit

class RootViewController: UIViewController{
    private lazy var addTodoItemButton = UIButton(type: .system)
    private var addTodoItemButtonXconstraint: NSLayoutConstraint?
    private var addTodoItemButtonYconstraint: NSLayoutConstraint?

    private lazy var tableView = UITableView.init(frame: .zero, style: UITableView.Style.plain)

    private let handler = TodoListHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Мои дела"
        view.backgroundColor = UIColor(named: "Back.Primary")

        setupAddTodoItemButton()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        setupConstraintForAddTodoItemButton()
    }

    @objc func openTodoItemEditor() {
        let navController = UINavigationController(rootViewController: EditTodoItemViewController(handler: handler))
        present(navController, animated: true)
    }


    private func setupAddTodoItemButton() {
        addTodoItemButton.translatesAutoresizingMaskIntoConstraints = false


        addTodoItemButton.addTarget(self, action: #selector(openTodoItemEditor), for: .touchUpInside)
        let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor(named: "Color.White")!, UIColor(named: "Color.Blue")!])
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
}
