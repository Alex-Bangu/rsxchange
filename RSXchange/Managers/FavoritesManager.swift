import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var osrsFavoriteItems: [Item] = []
    @Published private(set) var rs3FavoriteItems: [Item] = []
    
    private let osrsUserDefaultsKey = "osrsFavoriteItems"
    private let rs3UserDefaultsKey = "rs3FavoriteItems"
    
    private init() {
        loadFavorites()
    }
    
    func addFavorite(_ item: Item) {
        guard let game = item.game else { return }
        if !isFavorite(item) {
            switch game {
            case .osrs:
                osrsFavoriteItems.append(item)
            case .rs3:
                rs3FavoriteItems.append(item)
            }
            saveFavorites()
        }
    }
    
    func removeFavorite(_ item: Item) {
        guard let game = item.game else { return }
        switch game {
        case .osrs:
            osrsFavoriteItems.removeAll { $0.id == item.id }
        case .rs3:
            rs3FavoriteItems.removeAll { $0.id == item.id }
        }
        saveFavorites()
    }
    
    func isFavorite(_ item: Item) -> Bool {
        guard let game = item.game else { return false }
        switch game {
        case .osrs:
            return osrsFavoriteItems.contains { $0.id == item.id }
        case .rs3:
            return rs3FavoriteItems.contains { $0.id == item.id }
        }
    }
    
    func getFavorites(for game: Game) -> [Item] {
        switch game {
        case .osrs:
            return osrsFavoriteItems
        case .rs3:
            return rs3FavoriteItems
        }
    }
    
    private func saveFavorites() {
        do {
            let osrsData = try JSONEncoder().encode(osrsFavoriteItems)
            UserDefaults.standard.set(osrsData, forKey: osrsUserDefaultsKey)
            
            let rs3Data = try JSONEncoder().encode(rs3FavoriteItems)
            UserDefaults.standard.set(rs3Data, forKey: rs3UserDefaultsKey)
        } catch {
            print("Error saving favorites: \(error.localizedDescription)")
        }
    }
    
    private func loadFavorites() {
        if let osrsData = UserDefaults.standard.data(forKey: osrsUserDefaultsKey) {
            do {
                osrsFavoriteItems = try JSONDecoder().decode([Item].self, from: osrsData)
            } catch {
                print("Error loading OSRS favorites: \(error.localizedDescription)")
            }
        }
        
        if let rs3Data = UserDefaults.standard.data(forKey: rs3UserDefaultsKey) {
            do {
                rs3FavoriteItems = try JSONDecoder().decode([Item].self, from: rs3Data)
            } catch {
                print("Error loading RS3 favorites: \(error.localizedDescription)")
            }
        }
    }
}