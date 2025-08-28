
import SwiftUI
import Charts

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    private let game: Game
    @Environment(\.colorScheme) var colorScheme

    init(item: Item, game: Game) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item))
        self.game = game
    }

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.darkSand : Color.sand).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if let detailItem = viewModel.detailItem {
                        // Item Image
                        AsyncImage(url: detailItem.item.icon_large) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        // Item Name
                        Text(detailItem.item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Divider()

                        // Description
                        Text(detailItem.item.description)
                            .font(.body)
                        
                        Divider()

                        // Price Trends
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Price Trends")
                                .font(.title2)
                                .fontWeight(.semibold)
                            HStack {
                                Text("30 Day:")
                                Text(detailItem.item.day30.change)
                                    .foregroundColor(trendColor(for: detailItem.item.day30.trend))
                            }
                            HStack {
                                Text("90 Day:")
                                Text(detailItem.item.day90.change)
                                    .foregroundColor(trendColor(for: detailItem.item.day90.trend))
                            }
                            HStack {
                                Text("180 Day:")
                                Text(detailItem.item.day180.change)
                                    .foregroundColor(trendColor(for: detailItem.item.day180.trend))
                            }
                        }

                        Divider()

                        // Graph
                        if let graphData = viewModel.graphData {
                            Text("Price Graph")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Chart {
                                ForEach(graphData.daily.sorted(by: <), id: \.key) { key, value in
                                    LineMark(
                                        x: .value("Date", Date(timeIntervalSince1970: Double(key)! / 1000)),
                                        y: .value("Price", value),
                                        series: .value("Type", "Daily")
                                    )
                                    .foregroundStyle(by: .value("Type", "Daily"))
                                }
                                ForEach(graphData.average.sorted(by: <), id: \.key) { key, value in
                                    LineMark(
                                        x: .value("Date", Date(timeIntervalSince1970: Double(key)! / 1000)),
                                        y: .value("Price", value),
                                        series: .value("Type", "Average")
                                    )
                                    .foregroundStyle(by: .value("Type", "Average"))
                                }
                            }
                            .chartForegroundStyleScale([
                                "Daily": .blue,
                                "Average": .green
                            ])
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }
                            .frame(height: 200)
                        }
                        
                        // Longer Description from Wiki
                        if let wikiDescription = viewModel.wikiDescription {
                            Text("More Details")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(wikiDescription)
                                .font(.body)
                        }
                        
                        // Wiki Link
                        if let wikiURL = viewModel.wikiURL {
                            Link("View on Wiki", destination: wikiURL)
                                .padding(.top)
                                .foregroundColor(colorScheme == .dark ? .yellow : .blue)
                        }
                    }
                }
                .padding()
            }
        }
        .accentColor(colorScheme == .dark ? .yellow : .sand)
        .onAppear {
            viewModel.fetchData(for: game)
        }
        .navigationTitle(viewModel.item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if favoritesManager.isFavorite(viewModel.item) {
                        favoritesManager.removeFavorite(viewModel.item)
                    } else {
                        favoritesManager.addFavorite(viewModel.item)
                    }
                }) {
                    Image(systemName: favoritesManager.isFavorite(viewModel.item) ? "star.fill" : "star")
                }
            }
        }
    }

    func trendColor(for trend: String) -> Color {
        switch trend {
        case "positive":
            return .green
        case "negative":
            return .red
        default:
            return .primary
        }
    }
}
