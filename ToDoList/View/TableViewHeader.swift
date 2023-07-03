import UIKit

class TableViewHeader: UITableViewHeaderFooterView {

    var valueDidChange: (() -> Void)?

    static let identifier: String = "TableViewHeaderCell"

    public var textView = UILabel()
    private let buttonView = UIButton()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews(){
        setupText()
        setupButton()
        setupContentView()
        setupContents()
    }

    func setupText(){
        textView.textColor = UIColor.labelTertiary
        textView.text = "Выполнено - \(rootViewModel.fileCache.todoItems.filter( {$0.isDone} ).count)"
    }

    func setupButton(){
        buttonView.setTitle("Показать", for: .normal)
        buttonView.setTitle("Скрыть", for: .selected)
        buttonView.setTitleColor(.systemBlue, for: .normal)
        buttonView.addTarget(self, action: #selector(pressedButtonHeader), for: .touchUpInside)
    }

    func setupContentView(){
        contentView.backgroundColor = UIColor.backPrimary
        contentView.addSubview(textView)
        contentView.addSubview(buttonView)
    }

    func setupContents() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            buttonView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            buttonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @objc func pressedButtonHeader(_ button: UIButton) {
        rootViewModel.switchPresentationStatus()
        buttonView.isSelected.toggle()
        self.valueDidChange?()
    }
}
