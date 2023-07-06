import UIKit

final class CellView: UITableViewCell {

    var valueDidChange: (() -> Void)?

    static let identifier: String = "TableViewCell"

    private let strikethroughStyle = NSAttributedString(
        string: "Text",
        attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
    )

// MARK: Views
    private var isDoneView = UIButton()

    private let mainView = UIStackView()
    private var importanceView = UIImageView()
    private let textStackView = UIStackView()
    private let textView = UILabel()
    private var deadLineStackView = UIStackView()
    private let calendarImage = UIImageView()
    private var deadLineLabel = UILabel()

    private let chevronView = UIImageView()

// MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupCellView()
        constructCellView()
        setupCellViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(_ item: TodoItem){
        textView.text = item.text
        textView.textColor = UIColor.labelPrimary
        textView.strikeThrough(item.isDone)

        var colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.supportSeparator])

        switch item.importance {
        case .low:
            let configuration = UIImage.SymbolConfiguration(pointSize: 16.5).applying(UIImage.SymbolConfiguration(weight: .bold))
            let importanceImage = UIImage(systemName: "arrow.down", withConfiguration: configuration)?
                .withTintColor(UIColor.colorGray, renderingMode: .alwaysOriginal)

            importanceView.image = importanceImage

            importanceView.isHidden = false
        case .important:
            colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.colorRed])

            let configuration = UIImage.SymbolConfiguration(pointSize: 16.5).applying(UIImage.SymbolConfiguration(weight: .bold))
            let importanceImage = UIImage(systemName: "exclamationmark.2", withConfiguration: configuration)?
                .withTintColor(UIColor.colorRed, renderingMode: .alwaysOriginal)

            importanceView.image = importanceImage

            importanceView.isHidden = false
        default:
            importanceView.isHidden = true
        }

        switch item.isDone {
        case true:
            colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.colorWhite, UIColor.colorGreen])
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: iconConfig)
            isDoneView.setImage(icon, for: UIControl.State.normal)

            textView.textColor = UIColor.labelTertiary

            importanceView.isHidden = true
        case false:

            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "circle", withConfiguration: iconConfig)

            isDoneView.setImage(icon, for: UIControl.State.normal)
        }

        if let deadline = item.deadLine{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            deadLineLabel.text = dateFormatter.string(from: deadline)
            deadLineStackView.isHidden = false
        } else {
            deadLineStackView.isHidden = true
        }
    }

// MARK: - UI Setup
    func setupCellView() {
        contentView.backgroundColor = UIColor.backSecondary

        // isDone Part
        isDoneView.addTarget(self, action: #selector(isDoneButtonTapped), for: .touchUpInside)

        // main Part
        setupMainView()
        setupTextStackView()
        setupDeadLineStackView()

        // chevron thing
        chevronView.image = UIImage(systemName: "chevron.right", withConfiguration:
                                        UIImage.SymbolConfiguration(pointSize: 12)
                                .applying(UIImage.SymbolConfiguration(paletteColors: [UIColor.colorGray])))
    }

    func setupMainView() {
        mainView.axis = .horizontal
        mainView.alignment = .center
        mainView.spacing = 3
    }

    func setupTextStackView(){
        textView.numberOfLines = 3
        textView.font = UIFont.Body
        textView.textColor = UIColor.labelPrimary

        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.distribution = .fill
    }

    func setupDeadLineStackView(){
        calendarImage.tintColor = UIColor.labelTertiary
        calendarImage.image = UIImage(systemName: "calendar")

        deadLineLabel.textColor = UIColor.labelTertiary
        deadLineLabel.font = UIFont.Subhead

        deadLineStackView.axis = .horizontal
        deadLineStackView.alignment = .center
        deadLineStackView.spacing = 2
    }

// MARK: - UI Construction
    func constructCellView() {
        contentView.addSubview(isDoneView)
        contentView.addSubview(mainView)
        contentView.addSubview(chevronView)

        mainView.addArrangedSubview(importanceView)
        mainView.addArrangedSubview(textStackView)

        textStackView.addArrangedSubview(textView)
        textStackView.addArrangedSubview(deadLineStackView)

        deadLineStackView.addArrangedSubview(calendarImage)
        deadLineStackView.addArrangedSubview(deadLineLabel)
    }

// MARK: - UI Constraints
    func setupCellViewConstraints() {
        [isDoneView, mainView, importanceView, textStackView, textView, deadLineStackView, calendarImage, deadLineLabel, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            isDoneView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            isDoneView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),

            mainView.leadingAnchor.constraint(equalTo: isDoneView.trailingAnchor, constant: 10),
            mainView.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -16),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    @objc func isDoneButtonTapped(_ sender: UIButton) {
        self.valueDidChange?()
    }
}

// MARK: UILabel StrikeThough
extension UILabel {
    func strikeThrough(_ isStrikeThrough: Bool = true) {
        guard let text = self.text else {
            return
        }

        if isStrikeThrough {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        } else {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: [""],
                                         range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        }
    }
}
