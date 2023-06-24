import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "dd MMMM yyyy"
    return dateFormatter
}()

extension Date {
    var dateForLabel: String { dateFormatter.string(from: self) }
}
