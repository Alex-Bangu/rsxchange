import SwiftUI

struct ItemRow: View {
    let item: Item

    var body: some View {
        HStack {
            AsyncImage(url: item.icon_large) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                priceChangeView
            }
        }
    }

    private var priceChangeView: some View {
        HStack(spacing: 4) {
            if let currentPrice = item.current?.price {
                Text(currentPrice)
                    .font(.subheadline)
            }
            if let today = item.today {
                priceTrendIcon(for: today.trend)
                Text(today.price)
                    .font(.subheadline)
                    .foregroundColor(priceTrendColor(for: today.trend))
            }
        }
    }

    private func priceTrendIcon(for trend: String?) -> some View {
        let iconName: String
        switch trend {
        case "positive":
            iconName = "arrow.up"
        case "negative":
            iconName = "arrow.down"
        default:
            iconName = "arrow.right"
        }
        return Image(systemName: iconName).foregroundColor(priceTrendColor(for: trend))
    }

    private func priceTrendColor(for trend: String?) -> Color {
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