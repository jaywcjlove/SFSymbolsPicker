//
//  SFSymbolsPickerVM.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//

import Foundation
import SwiftUI

@MainActor
public class SFSymbolsPickerViewModel: ObservableObject {
    private let loader: SymbolLoader = SymbolLoader()
    private var searchTask: Task<Void, Never>?
    let autoDismiss: Bool
    let prompt: String
    @Published var searchText = ""
    @Published var symbols: [String] = []
    @Published var isLoading: Bool = true
    @Published var isLoadingMore: Bool = false
    private var isSearching: Bool = false
    
    init(prompt: String, autoDismiss: Bool) {
        self.prompt = prompt
        self.autoDismiss = autoDismiss
        NotificationCenter.default.addObserver(self, selector: #selector(updateSymbols), name: .symbolsLoaded, object: nil)
        self.loadSymbols()
    }
    
    @objc private func updateSymbols() {
        symbols = loader.getSymbols()
        isLoading = false
    }
    
    public var hasMoreSymbols: Bool {
        return !isSearching && loader.hasMoreSymbols()
    }
    
    public func loadSymbols() {
        symbols = loader.getSymbols()
        isLoading = false
    }
    
    public func loadMoreSymbols() {
        guard !isLoadingMore && hasMoreSymbols else { return }
        isLoadingMore = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let newSymbols = self.loader.loadNextPage()
            
            DispatchQueue.main.async {
                if !newSymbols.isEmpty {
                    self.symbols = self.loader.getSymbols()
                }
                self.isLoadingMore = false
            }
        }
    }
    
    public func searchSymbols(with name: String) {
        // Cancel any existing search task
        searchTask?.cancel()
        // Create a new search task with debounce
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            
            DispatchQueue.main.async {
                self.symbols = self.loader.getSymbols(named: name)
                self.isLoading = false
                self.isSearching = true
            }
        }
    }
    
    public func reset() {
        loader.resetPagination()
        symbols.removeAll()
        isLoading = true
        isSearching = false
        isLoadingMore = false
        searchTask?.cancel()
        loadSymbols()
    }
}
