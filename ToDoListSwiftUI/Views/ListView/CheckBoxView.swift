import SwiftUI

struct CheckBoxView: View {
    let isDone: Bool
    let importance: Importance

    init(isDone: Bool = false, importance: Importance = .basic) {
        self.isDone = isDone
        self.importance = importance
    }

    var body: some View {
        if isDone {
            Image(systemName: "checkmark.circle.fill")
                .frame(width: 24.0, height: 24.0)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color("Color.White"), Color("Color.Green"))
                .font(.system(size: 24))
        } else {
            if importance == .important {
                Image(systemName: "circle")
                    .frame(width: 24.0, height: 24.0)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color("Color.Red"))
                    .font(.system(size: 24))
            } else {
                Image(systemName: "circle")
                    .frame(width: 24.0, height: 24.0)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color("Support.Separator"))
                    .font(.system(size: 24))
            }
        }
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    static var previews: some View {
        CheckBoxView(importance: .important)
            .previewLayout(.sizeThatFits)
    }
}
