import SwiftUI

struct TodoItemView: View {
    var body: some View {
        ZStack {
            Color("Back.Primary")
                .ignoresSafeArea()

            
            Text("Hello, World!")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView()
    }
}
