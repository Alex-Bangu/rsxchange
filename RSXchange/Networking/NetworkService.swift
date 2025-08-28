
import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

class NetworkService {
    private let baseURL = "https://services.runescape.com/m=itemdb_"

    func searchItems(query: String, for game: Game, page: Int) async throws -> [Item] {
        let urlString = "\(baseURL)\(game.rawValue)/api/catalogue/search.json"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "simple", value: "1"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        do {
            var searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            for i in 0..<searchResponse.results.count {
                searchResponse.results[i].game = game
            }
            return searchResponse.results
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getItemDetails(for itemID: Int, in game: Game) async throws -> DetailItem {
        let urlString = "\(baseURL)\(game.rawValue)/api/catalogue/detail.json?item=\(itemID)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(DetailItem.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getGraphData(for itemID: Int, in game: Game) async throws -> GraphData {
        let urlString = "https://services.runescape.com/m=itemdb_\(game.rawValue)/api/graph/\(itemID).json"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(GraphData.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getWikiURL(for itemName: String, in game: Game) async throws -> WikiPage? {
        let baseURL: String
        switch game {
        case .osrs:
            baseURL = "https://oldschool.runescape.wiki/api.php"
        case .rs3:
            baseURL = "https://runescape.wiki/api.php"
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "info|extracts"),
            URLQueryItem(name: "inprop", value: "url"),
            URLQueryItem(name: "titles", value: itemName),
            URLQueryItem(name: "explaintext", value: "true")
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let wikiInfo = try JSONDecoder().decode(WikiInfo.self, from: data)
            return wikiInfo.query.pages.values.first
        } catch {
            throw NetworkError.decodingError
        }
    }
}
