import SwiftUI

struct ItemSearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var selectedItem: Item?
    @Environment(\.colorScheme) var colorScheme

    var favoritesList: [Item] {
        switch viewModel.game {
        case .osrs:
            return favoritesManager.osrsFavoriteItems
        case .rs3:
            return favoritesManager.rs3FavoriteItems
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.darkSand : Color.sand).edgesIgnoringSafeArea(.all)
                VStack {
                    Picker("Game", selection: $viewModel.game) {
                        Text("OSRS").tag(Game.osrs)
                        Text("RS3").tag(Game.rs3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    

                    if viewModel.isLoading && viewModel.items.isEmpty {
                        ProgressView()
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                        Spacer()
                    } else if viewModel.items.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
                        Text("No results found for \(viewModel.searchText)")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List {
                            if viewModel.searchText.isEmpty {
                                Section(header: Text("Favorites")) {
                                    ForEach(favoritesList) { item in
                                        ItemRow(item: item)
                                            .onTapGesture {
                                                selectedItem = item
                                            }
                                            .listRowBackground(Color.clear)
                                    }
                                }
                            }
                            
                            if !viewModel.searchText.isEmpty {
                                Section(header: Text("Search Results")) {
                                    ForEach(viewModel.items) { item in
                                        ItemRow(item: item)
                                            .onTapGesture {
                                                selectedItem = item
                                            }
                                            .onAppear {
                                                if item == viewModel.items.last {
                                                    viewModel.loadMoreItems()
                                                }
                                            }
                                            .listRowBackground(Color.clear)
                                    }
                                    if viewModel.isLoading {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(
                            Group {
                                if let selectedItem = selectedItem {
                                NavigationLink(
                                        destination: ItemDetailView(item: selectedItem, game: viewModel.game),
                                        isActive: Binding(
                                            get: { self.selectedItem != nil },
                                            set: { isActive in
                                                if !isActive {
                                                    self.selectedItem = nil
                                                }
                                            }
                                        )
                                    ) {
                                        EmptyView()
                                    }
                                }
                            }
                        )
                    }
                }
                .navigationTitle("RSXchange")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitleColor()
                .searchable(text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.search()
                }
            }
        }
        .accentColor(.yellow)
    }
}

