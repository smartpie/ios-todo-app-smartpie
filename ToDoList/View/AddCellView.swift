import UIKit

final class AddCellView: UITableViewCell, UITextFieldDelegate {

    var addCellTapped: (() -> Void)?

    static let identifier: String = "TableViewAddCell"

    private let textView = UILabel()
    private let imagePlus = UIImage(systemName: "plus.circle.fill")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupText()
        setupViews()
        setupConstraints()
        addCellTapRecogniser()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        contentView.backgroundColor = UIColor.backSecondary
        contentView.addSubview(textView)
    }

    func setupText(){
        textView.text = "Новое"
        textView.textColor = UIColor.labelTertiary
    }

    func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16 + 24 + 12),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    func addCellTapRecogniser() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAddCell))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tap)
    }

    @objc func clickAddCell(switcher: UISwitch) {
        addCellTapped?()
    }
}
