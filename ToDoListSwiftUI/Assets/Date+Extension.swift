import Foundation

private let dateFormatterWithYear: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "dd MMMM yyyy"
    return dateFormatter
}()

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "dd MMMM"
    return dateFormatter
}()

extension Date {
    var dateForLabel: String { dateFormatter.string(from: self) }
    var dateForLabelWithYear: String { dateFormatterWithYear.string(from: self) }
}
