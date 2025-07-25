//
//  SymbolLoader.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//
import Foundation

/// A class responsible for loading and managing SF Symbols from the system
/// 
/// This class provides asynchronous loading of all available SF Symbols from the CoreGlyphs bundle,
/// implements pagination for performance optimization, and notifies observers when symbols are loaded.
public class SymbolLoader: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Array containing all available SF Symbol names
    private final var allSymbols: [String] = []
    
    /// Array containing currently loaded symbols for display (paginated)
    private var loadedSymbols: [String] = []
    
    /// Number of symbols to load per page for performance optimization
    private let symbolsPerPage = 100
    private var currentPage = 0
    
    /// Counter to prevent infinite retry attempts when loading fails
    private var retryCount = 0
    
    /// Flag indicating whether symbols are currently being loaded
    private var isLoading: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the SymbolLoader and starts asynchronous symbol loading
    public init() {
        // Start loading symbols asynchronously to avoid blocking the main thread
        Task {
            await loadAllSymbols()
        }
    }
    
    public func hasMoreSymbols() -> Bool {
        let nextPageStart = currentPage * symbolsPerPage
        return nextPageStart < allSymbols.count
    }
    
    // MARK: - Private Methods
    /// Loads all available SF Symbols from the system CoreGlyphs bundle
    /// 
    /// This method attempts to access the CoreGlyphs bundle and reads the name_availability.plist file
    /// to extract all available SF Symbol names. It includes retry logic for reliability and implements
    /// pagination for performance optimization.
    ///
    /// - Note: If loading fails, the method will automatically retry up to 3 times with exponential backoff
    /// - Warning: This method executes on a background thread and notifies the main thread via NotificationCenter when complete
    private func loadAllSymbols() async {
        // Prevent multiple simultaneous loading attempts
        guard !isLoading else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let symbols = try await loadSymbolsFromBundle()
            // Process symbols on background thread for better performance
            let sortedSymbols = symbols.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            // Update properties atomically
            await MainActor.run {
                self.allSymbols = sortedSymbols
                self.loadedSymbols = Array(sortedSymbols.prefix(self.symbolsPerPage))
                self.retryCount = 0 // Reset retry count on success
                
                // Notify observers that symbols have been loaded successfully
                NotificationCenter.default.post(name: .symbolsLoaded, object: nil)
            }
            print("Successfully loaded \(symbols.count) SF Symbols.")
        } catch {
            print("Failed to load SF Symbols: \(error.localizedDescription)")
            await handleLoadingFailure()
        }
    }
    
    /// Attempts to load symbols from the CoreGlyphs bundle
    /// - Returns: Array of symbol names
    /// - Throws: SymbolLoadingError if loading fails
    private func loadSymbolsFromBundle() async throws -> [String] {
        // Attempt to access the system CoreGlyphs bundle
        guard let bundle = Bundle(identifier: "com.apple.CoreGlyphs") else {
            throw SymbolLoadingError.bundleNotFound
        }
        
        // Locate the plist resource file
        guard let resourcePath = bundle.path(forResource: "name_availability", ofType: "plist") else {
            throw SymbolLoadingError.resourceNotFound
        }
        
        // Load and parse the plist file
        guard let plist = NSDictionary(contentsOfFile: resourcePath) else {
            throw SymbolLoadingError.invalidPlistFormat
        }
        
        // Extract symbols dictionary
        guard let plistSymbols = plist["symbols"] as? [String: Any] else {
            throw SymbolLoadingError.symbolsNotFound
        }
        
        // Filter out valid symbol names (non-empty strings)
        let symbolNames = plistSymbols.keys.compactMap { key -> String? in
            return key.isEmpty ? nil : key
        }
        
        guard !symbolNames.isEmpty else {
            throw SymbolLoadingError.noValidSymbols
        }
        
        return symbolNames
    }
    
    /// Handles loading failure with retry logic
    private func handleLoadingFailure() async {
        guard retryCount < 3 else {
            print("Failed to load SF Symbols after 3 attempts. Giving up.")
            await MainActor.run {
                NotificationCenter.default.post(name: .symbolsLoadingFailed, object: nil)
            }
            return
        }
        
        retryCount += 1
        let delay = UInt64(pow(2.0, Double(retryCount)) * 100_000_000) // Exponential backoff: 0.2s, 0.4s, 0.8s
        print("Retrying SF Symbols loading... Attempt \(retryCount)/3")
        try? await Task.sleep(nanoseconds: delay)
        await loadAllSymbols()
    }
    
    /// Errors that can occur during symbol loading
    private enum SymbolLoadingError: LocalizedError {
        case bundleNotFound
        case resourceNotFound
        case invalidPlistFormat
        case symbolsNotFound
        case noValidSymbols
        var errorDescription: String? {
            switch self {
            case .bundleNotFound: "CoreGlyphs bundle not found"
            case .resourceNotFound: "name_availability.plist resource not found"
            case .invalidPlistFormat: "Invalid plist format"
            case .symbolsNotFound: "Symbols dictionary not found in plist"
            case .noValidSymbols: "No valid symbols found"
            }
        }
    }
    
    public func searchSymbols(query: String) -> [String] {
        if query.isEmpty { return [] }
        // First try exact matches
        let exactMatches = allSymbols.filter { $0.lowercased().starts(with: query.lowercased()) }
        if !exactMatches.isEmpty {
            return exactMatches
        }
        
        // Then try fuzzy matches
        return allSymbols.filter { $0.fuzzyMatch(query) }
    }
    public func getSymbols() -> [String] {
        if currentPage == 0 {
            currentPage = 1
            let endIndex = min(symbolsPerPage, allSymbols.count)
            loadedSymbols = Array(allSymbols[0..<endIndex])
        }
        return loadedSymbols
    }
    
    public func getSymbols(named name: String) -> [String] {
        if name.isEmpty { return [] }
        // First try exact matches
        let exactMatches = allSymbols.filter { $0.lowercased().starts(with: name.lowercased()) }
        if !exactMatches.isEmpty {
            return exactMatches
        }
        // Then try fuzzy matches
        return allSymbols.filter { $0.fuzzyMatch(name) }
    }
    
    public func loadNextPage() -> [String] {
        guard hasMoreSymbols() else { return [] }
        currentPage += 1
        let startIndex = (currentPage - 1) * symbolsPerPage
        let endIndex = min(startIndex + symbolsPerPage, allSymbols.count)
        let newSymbols = Array(allSymbols[startIndex..<endIndex])
        loadedSymbols.append(contentsOf: newSymbols)
        return newSymbols
    }
    public func resetPagination() {
        currentPage = 0
        loadedSymbols.removeAll()
    }
}

// MARK: - Notification Extensions

/// Extension to define custom notification names for the SymbolLoader
extension Notification.Name {
    /// Notification posted when SF Symbols have been successfully loaded
    /// 
    /// This notification is sent on the main thread when the SymbolLoader has finished
    /// loading all available SF Symbols from the system. Observers can listen for this
    /// notification to update their UI accordingly.
    static let symbolsLoaded = Notification.Name("symbolsLoaded")
    
    /// Notification posted when SF Symbols loading has failed after all retry attempts
    /// 
    /// This notification is sent when the SymbolLoader fails to load symbols after
    /// the maximum number of retry attempts.
    static let symbolsLoadingFailed = Notification.Name("symbolsLoadingFailed")
}

private extension String {
    func fuzzyMatch(_ pattern: String) -> Bool {
        let pattern = pattern.lowercased()
        let string = self.lowercased()
        
        if pattern.isEmpty { return true }
        if string.isEmpty { return false }
        
        var patternIndex = pattern.startIndex
        var stringIndex = string.startIndex
        
        while patternIndex < pattern.endIndex && stringIndex < string.endIndex {
            if pattern[patternIndex] == string[stringIndex] {
                patternIndex = pattern.index(after: patternIndex)
            }
            stringIndex = string.index(after: stringIndex)
        }
        
        return patternIndex == pattern.endIndex
    }
}
