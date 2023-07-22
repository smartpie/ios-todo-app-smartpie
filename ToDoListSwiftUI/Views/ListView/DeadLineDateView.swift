import SwiftUI

struct DeadLineDateView: View {
    let deadLine: Date?
    var formatter: DateFormatter = DateFormatter()

    init(deadLine: Date? = nil) {
        self.deadLine = deadLine

        self.formatter.dateFormat = "dd MMMM"
    }

    var body: some View {
        if let date = deadLine {
            HStack(alignment: .center, spacing: 2.0) {
                Image(systemName: "calendar")
                    .font(.system(size: 13))

                Text(self.formatter.string(from: date))
                    .font(.system(size: 15))
            }
            .frame(height: 20.0)
            .foregroundColor(Color("Label.Tertiary"))
        } else {
            EmptyView()
        }

    }
}

struct DeadLineDateView_Previews: PreviewProvider {
    static var previews: some View {
        DeadLineDateView(deadLine: Date())
            .previewLayout(.sizeThatFits)
    }
}
