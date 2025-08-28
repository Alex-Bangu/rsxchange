
import Foundation

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var detailItem: DetailItem?
    @Published var graphData: GraphData?
    @Published var wikiURL: URL?
    @Published var wikiDescription: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService = NetworkService()
    let item: Item

    init(item: Item) {
        self.item = item
    }

    func fetchData(for game: Game) {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                async let detail = networkService.getItemDetails(for: item.id, in: game)
                async let graph = networkService.getGraphData(for: item.id, in: game)
                async let wikiPage = networkService.getWikiURL(for: item.name, in: game)
                
                self.detailItem = try await detail
                self.graphData = try await graph
                
                let fetchedWikiPage = try await wikiPage
                self.wikiURL = fetchedWikiPage?.fullurl
                self.wikiDescription = cleanWikiDescription(fetchedWikiPage?.extract)
                
            } catch {
                errorMessage = "Failed to fetch item details: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    private func cleanWikiDescription(_ description: String?) -> String? {
        guard let description = description else { return nil }
        
        let lines = description.components(separatedBy: .newlines)
        let cleanedLines = lines.filter {
            let trimmedLine = $0.trimmingCharacters(in: .whitespaces)
            return !trimmedLine.isEmpty && !trimmedLine.hasPrefix("==")
        }
        return cleanedLines.joined(separator: "\n")
    }
}
