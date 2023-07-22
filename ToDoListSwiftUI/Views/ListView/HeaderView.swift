import SwiftUI

struct HeaderView: View {
    let doneCount: Int

    init(doneCount: Int = 0) {
        self.doneCount = doneCount
    }

    var body: some View {
        Text("Выполнено")
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
            .previewLayout(.sizeThatFits)
    }
}
