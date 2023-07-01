import UIKit

final class CellView: UITableViewCell {

    var valueDidChange: (() -> Void)?

    static let identifier: String = "TableViewCell"

    private let stackTextViews = UIStackView()
    private let textView = UILabel()
    private var stackDeadline = UIStackView()
    private let calendarImage = UIImageView(image: UIImage(systemName: "calendar"))
    private var deadlineView = UILabel()

    private var leftStackView = UIStackView()
    private var isDoneView = UIButton()
    private var importanceView = UIImageView()


    private let chevronView = UIImageView(image:
                                    UIImage(systemName: "chevron.right", withConfiguration:
                                                UIImage.SymbolConfiguration(pointSize: 12)
                                        .applying(UIImage.SymbolConfiguration(paletteColors: [UIColor.colorGray]))))

    private let strikethroughStyle = NSAttributedString(
        string: "Text",
        attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
    )

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(_ item: TodoItem){

        textView.text = item.text
        textView.textColor = UIColor.labelPrimary
        textView.strikeThrough(item.isDone)

        if item.isDone == true{
            let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.colorWhite, UIColor.colorGreen])
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: iconConfig)

            isDoneView.setImage(icon, for: UIControl.State.normal)
            textView.textColor = UIColor.labelTertiary
            importanceView.isHidden = true
        } else if item.importance == .important{
            let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.colorRed])
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "circle", withConfiguration: iconConfig)

            isDoneView.setImage(icon, for: UIControl.State.normal)
            importanceView.isHidden = false

            let configuration = UIImage.SymbolConfiguration(pointSize: 17).applying(UIImage.SymbolConfiguration(weight: .bold))
            let importanceImage = UIImage(systemName: "exclamationmark.2", withConfiguration: configuration)?
                .withTintColor(UIColor.colorRed, renderingMode: .alwaysOriginal)

            importanceView.image = importanceImage
        } else if item.importance == .low {
            let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.supportSeparator])
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "circle", withConfiguration: iconConfig)

            isDoneView.setImage(icon, for: UIControl.State.normal)
            importanceView.isHidden = false

            let configuration = UIImage.SymbolConfiguration(pointSize: 17).applying(UIImage.SymbolConfiguration(weight: .bold))
            let importanceImage = UIImage(systemName: "arrow.down", withConfiguration: configuration)?
                .withTintColor(UIColor.colorGray, renderingMode: .alwaysOriginal)

            importanceView.image = importanceImage
        } else {
            let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [UIColor.supportSeparator])
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 24).applying(colorsConfig)
            let icon = UIImage(systemName: "circle", withConfiguration: iconConfig)

            isDoneView.setImage(icon, for: UIControl.State.normal)
            importanceView.isHidden = true
        }

        if let deadline = item.deadLine{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            deadlineView.text = dateFormatter.string(from: deadline)
            stackDeadline.isHidden = false
        } else {
            stackDeadline.isHidden = true
        }
    }

    func setupViews(){
        contentView.backgroundColor = UIColor.backSecondary
        setupStackStatusViews()
        setupTextView()
        setupDeadlineView()
        setupStackTextView()

        contentView.addSubview(leftStackView)
        contentView.addSubview(stackTextViews)
        contentView.addSubview(chevronView)
    }

    func setupStackStatusViews(){
        isDoneView.addTarget(self, action: #selector(circleStatViewTapped), for: .touchUpInside)

        leftStackView.axis = .horizontal
        leftStackView.alignment = .center
        leftStackView.spacing = 2

        leftStackView.addArrangedSubview(isDoneView)
        leftStackView.addArrangedSubview(importanceView)
    }

    func setupTextView(){
        textView.numberOfLines = 3
        textView.font = UIFont.Body
        textView.textColor = UIColor.labelPrimary
    }

    func setupDeadlineView(){
        calendarImage.tintColor = UIColor.labelTertiary
        deadlineView.textColor = UIColor.labelTertiary
        deadlineView.font = UIFont.Subhead

        stackDeadline.axis = .horizontal
        stackDeadline.alignment = .center
        stackDeadline.spacing = 2

        stackDeadline.addArrangedSubview(calendarImage)
        stackDeadline.addArrangedSubview(deadlineView)
    }

    func setupStackTextView(){
        stackTextViews.axis = .vertical
        stackTextViews.alignment = .leading
        stackTextViews.distribution = .fill

        stackTextViews.addArrangedSubview(textView)
        stackTextViews.addArrangedSubview(stackDeadline)
    }

    func setupConstraints() {
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        isDoneView.translatesAutoresizingMaskIntoConstraints = false
        importanceView.translatesAutoresizingMaskIntoConstraints = false
        stackTextViews.translatesAutoresizingMaskIntoConstraints = false
        calendarImage.translatesAutoresizingMaskIntoConstraints = false
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leftStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            importanceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            stackTextViews.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackTextViews.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackTextViews.leadingAnchor.constraint(equalTo: leftStackView.trailingAnchor, constant: 16),
            stackTextViews.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -16),

            calendarImage.heightAnchor.constraint(equalToConstant: 16),
            calendarImage.widthAnchor.constraint(equalToConstant: 16),

            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    @objc func circleStatViewTapped(_ sender: UIButton) {
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
