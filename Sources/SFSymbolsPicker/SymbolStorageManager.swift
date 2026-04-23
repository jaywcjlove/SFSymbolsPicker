//
//  SymbolStorageManager.swift
//  SFSymbolsPicker
//
//  
//

import Foundation
import SwiftUI

@MainActor
public final class SymbolStorageManager: ObservableObject {
    @Published public private(set) var favorites: [String]
    @Published public private(set) var recents: [String]

    private let userDefaults: UserDefaults
    private let favoritesKey: String
    private let recentsKey: String
    private let recentLimit: Int

    public init(
        userDefaults: UserDefaults = .standard,
        favoritesKey: String = "com.sfsymbolspicker.favorites",
        recentsKey: String = "com.sfsymbolspicker.recents",
        recentLimit: Int = 12
    ) {
        self.userDefaults = userDefaults
        self.favoritesKey = favoritesKey
        self.recentsKey = recentsKey
        self.recentLimit = max(1, recentLimit)
        self.favorites = userDefaults.stringArray(forKey: favoritesKey) ?? []
        self.recents = userDefaults.stringArray(forKey: recentsKey) ?? []
    }

    public func isFavorite(_ symbol: String) -> Bool {
        favorites.contains(symbol)
    }

    public func toggleFavorite(_ symbol: String) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            if let index = favorites.firstIndex(of: symbol) {
                favorites.remove(at: index)
            } else {
                favorites.insert(symbol, at: 0)
            }
        }

        saveFavorites()
    }

    public func addRecent(_ symbol: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            recents.removeAll { $0 == symbol }
            recents.insert(symbol, at: 0)

            if recents.count > recentLimit {
                recents = Array(recents.prefix(recentLimit))
            }
        }

        saveRecents()
    }

    public func favoriteSymbols(from symbols: [String], matching searchText: String = "") -> [String] {
        filter(symbols: favorites, availableSymbols: symbols, searchText: searchText)
    }

    public func recentSymbols(from symbols: [String], matching searchText: String = "") -> [String] {
        filter(symbols: recents, availableSymbols: symbols, searchText: searchText)
    }

    private func filter(symbols: [String], availableSymbols: [String], searchText: String) -> [String] {
        let available = Set(availableSymbols)
        let normalizedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return symbols.filter { symbol in
            guard available.contains(symbol) else { return false }
            guard !normalizedQuery.isEmpty else { return true }
            return symbol.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private func saveFavorites() {
        userDefaults.set(favorites, forKey: favoritesKey)
    }

    private func saveRecents() {
        userDefaults.set(recents, forKey: recentsKey)
    }
}
