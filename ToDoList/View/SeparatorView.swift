import UIKit

final class SeparatorView: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let line = UIView()
        line.backgroundColor = UIColor(named: "Support.Separator")
        line.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            line.topAnchor.constraint(equalTo: self.topAnchor),
            line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
