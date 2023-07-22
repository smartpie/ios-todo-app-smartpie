import SwiftUI

struct ListView: View {
    @ObservedObject private var model = ListViewModel.shared
    @State private var showCategorySelector: Bool = false
    @State var showDone: Bool = false
    @Environment(\.isPresented) var isPresented

    var body: some View {
        ZStack {
            NavigationStack {
                List() {
                    Section(header:
                        HStack {
                        Text("Выполнено — \(model.items.reduce(0, { $0 + ($1.isDone ? 1 : 0 ) }))")
                                .font(.system(size: 15))
                                .foregroundColor(Color("Label.Tertiary"))

                            Spacer()

                            Button(action: {showDone.toggle()}) {
                                if showDone {
                                    Text("Скрыть")
                                        .fontWeight(.bold)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("Color.Blue"))
                                } else {
                                    Text("Показать")
                                        .fontWeight(.bold)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("Color.Blue"))
                                }
                            }
                        }
//                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .padding(.top, 8)
                        .textCase(.none)
                    ) {
                        if showDone {
                            ForEach(model.items) { item in
                                CellView(item: item)
                            }
                            .onDelete(perform: deleteItems)
                        } else {
                            ForEach(model.items) { item in
                                if item.isDone == false {
                                    CellView(item: item)
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }

                        AddNewCellView()
                    }
                    .listRowInsets(EdgeInsets(top: 0,
                                              leading: 0,
                                              bottom: 0,
                                              trailing: 0))
                    .listSectionSeparator(.hidden)
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Мои дела")
                .navigationBarTitleDisplayMode(.large)
                .scrollContentBackground(.hidden)
                .background(Color("Back.Primary"))
            }

            VStack {
                Spacer()

                Button(action: {
                    showCategorySelector.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color("Color.White"), Color("Color.Blue"))
                        .font(.system(size: 44))
                }
                .padding(.bottom, 54.0)
                .shadow(color: Color(CGColor(red: 0, green: 49/255, blue: 102/255,  alpha: 0.3)),
                        radius: 20,
                        x: 0,
                        y: 8)
            }
            .ignoresSafeArea()
            .padding(.horizontal, 0.0)
        }
        .onAppear(perform: model.fetch)
    }

    private func deleteItems(indecies: IndexSet) {
        for index in indecies {
            do {
                try model.deleteTodoItem(item: model.items[index])
            } catch {

            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
