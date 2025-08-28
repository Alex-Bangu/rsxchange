import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchText = ""
    @Published var game: Game = .osrs {
        didSet {
            if oldValue != game {
                searchText = ""
                items = []
                errorMessage = nil
                page = 1
                canLoadMorePages = true
            }
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var page = 1
    private var canLoadMorePages = true
    private let networkService = NetworkService()

    func search() {
        items = []
        page = 1
        canLoadMorePages = true
        if !searchText.isEmpty {
            loadMoreItems()
        }
    }

    func loadMoreItems() {
        guard !isLoading && canLoadMorePages && !searchText.isEmpty else {
            return
        }
        
        isLoading = true
        
        Task {
            errorMessage = nil
            do {
                let newItems = try await networkService.searchItems(query: searchText, for: game, page: page)
                if newItems.isEmpty {
                    canLoadMorePages = false
                } else {
                    let uniqueNewItems = newItems.filter { newItem in
                        !self.items.contains { $0.id == newItem.id }
                    }
                    items.append(contentsOf: uniqueNewItems)
                    items.sort { $0.name < $1.name }
                    page += 1
                }
            } catch {
                errorMessage = "Failed to fetch items: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}