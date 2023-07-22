import SwiftUI

struct CellView: View {
    let item: TodoItem
    var valueDidChange: ((TodoItem) -> Void)

    init(item: TodoItem, valueDidChange: @escaping (TodoItem) -> Void = { _ in print("pressed")}) {
        self.item = item
        self.valueDidChange = valueDidChange
    }

    var body: some View {
        HStack(spacing: 0.0) {
            Button(action: {}) {
                CheckBoxView(isDone: item.isDone, importance: item.importance)
            }
            .onTapGesture {
                ListViewModel.shared.switchIsDone(item: self.item)
            }
                .padding(.trailing, 12.0)

            ImportanceSymbolView(isDone: item.isDone, importance: item.importance)
                .padding(.trailing, 2.0)

            VStack(alignment: .leading, spacing: 0.0) {
                if item.isDone == true {
                    Text(item.text)
                        .lineLimit(3)
                        .font(.system(size: 17))
                        .strikethrough()
                        .foregroundColor(Color("Label.Tertiary"))
                } else {
                    Text(item.text)
                        .lineLimit(3)
                        .font(.system(size: 17))
                }
                DeadLineDateView(deadLine: item.deadLine)
            }


            Spacer()

            Image(systemName: "chevron.right")
                .padding(.leading, 16.0)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color("Color.Gray"))
                .font(.system(size: 12))
                .fontWeight(.bold)
        }
        .padding(16)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CellView(item: TodoItem(text: "Hello, World!",
                                    importance: .basic,
                                    deadLine: Date(),
                                    isDone: false))
            CellView(item: TodoItem(text: "Hello, World! It's me Mario! Pupupu purururu. I'm a cat and you a piece of shit. I wana mess her up inside that. Will I be able to do that? :/",
                                    importance: .important,
                                    deadLine: Date(),
                                    isDone: true))
        }
        .previewLayout(.sizeThatFits)
    }
}

