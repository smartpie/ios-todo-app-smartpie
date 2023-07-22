import SwiftUI

struct AddNewCellView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12.0) {
            VStack {
                // Тут был плюсик, но он сплыл
            }
            .frame(width: 24.0, height: 24.0)

            Text("Новое")
                .foregroundColor(Color("Label.Tertiary"))

        }
        .padding(16.0)
    }
}

struct AddNewCellView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewCellView()
            .previewLayout(.sizeThatFits)
    }
}
