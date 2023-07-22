import SwiftUI

struct ImportanceSymbolView: View {
    let isDone: Bool
    let importance: Importance

    init(isDone: Bool = false, importance: Importance = .basic) {
        self.isDone = isDone
        self.importance = importance
    }

    var body: some View {
        if isDone {
            EmptyView()
        } else {
            switch importance {
            case .important:
                Image(systemName: "exclamationmark.2")
                    .foregroundColor(Color("Color.Red"))
                    .font(.system(size: 16.5))
                    .fontWeight(.bold)
            case .low:
                Image(systemName: "arrow.down")
                    .foregroundColor(Color("Color.Gray"))
                    .font(.system(size: 16.5))
                    .fontWeight(.bold)
            case .basic:
                EmptyView()
            }
        }
    }
}

struct ImportanceSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImportanceSymbolView(importance: .low)
                .previewDisplayName("Low")
            ImportanceSymbolView(importance: .basic)
                .previewDisplayName("Basic")
            ImportanceSymbolView(importance: .important)
                .previewDisplayName("Important")
        }
        .previewLayout(.sizeThatFits)
    }
}
