//
//  SFSymbolsPickerPanel.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//

import SwiftUI

public struct SFSymbolsPickerPanel: View {
    @Binding var selection: String
    @EnvironmentObject var vm: SFSymbolsPickerViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var storageManager = SymbolStorageManager()

    public init(selection: Binding<String>) {
        self._selection = selection
    }

    public var body: some View {
        VStack {
            if(vm.isLoading) {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 38, maximum: 45), spacing: 8)
                        ],
                        spacing: 8
                    ) {
                        symbolSection(title: "Favorites", symbols: favoriteSymbols)
                        symbolSection(title: "Recent", symbols: recentSymbols)
                        symbolSection(title: "All Symbols", symbols: vm.symbols)

                        if vm.hasMoreSymbols && vm.searchText.isEmpty {
                            if vm.isLoadingMore {
                                ProgressView()
                                    .padding()
                            } else {
                                Color.clear
                                    .frame(height: 1)
                                    .onAppear {
                                        vm.loadMoreSymbols()
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                #if os(macOS)
                .safeAreaInset(edge: .top, spacing: 0) {
                    SymbolPanelSearch(value: $vm.searchText, prompt: vm.prompt)
                }
                #endif
                .scrollDisabled(false)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10).onChanged { _ in }
                )
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .frame(maxWidth: .infinity)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.searchText, prompt: vm.prompt)
        #endif
        .onChange(of: selection) { oldValue, newValue in
            guard oldValue != newValue else { return }
            storageManager.addRecent(newValue)
            if (vm.autoDismiss) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: vm.searchText, initial: true) { oldValue, newValue in
            if(newValue.isEmpty || vm.searchText.isEmpty) {
                vm.reset()
            } else {
                vm.searchSymbols(with: newValue)
            }
        }
    }

    private var favoriteSymbols: [String] {
        storageManager.favoriteSymbols(from: vm.symbols, matching: vm.searchText)
    }

    private var recentSymbols: [String] {
        storageManager.recentSymbols(from: vm.symbols, matching: vm.searchText)
    }

    @ViewBuilder
    private func symbolSection(title: String, symbols: [String]) -> some View {
        if !symbols.isEmpty {
            Section {
                ForEach(symbols, id: \.self) { icon in
                    SymbolIcon(
                        symbolName: icon,
                        selection: $selection,
                        isFavorite: storageManager.isFavorite(icon),
                        onFavoriteToggle: {
                            storageManager.toggleFavorite(icon)
                        }
                    )
                    .id(icon)
                }
            } header: {
                sectionHeader(title: title)
            }
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .gridCellColumns(10)
    }
}

#Preview {
    @Previewable @ObservedObject var vm: SFSymbolsPickerViewModel = .init(prompt: "", autoDismiss: true)
    @Previewable @State var selection: String = "star.bubble"
    @Previewable @State var isPresented: Bool = false
    #if os(macOS)
        VStack(spacing: 23) {
            Button("Select a symbol") {
                isPresented.toggle()
            }
            .popover(isPresented: $isPresented) {
                SFSymbolsPickerPanel(selection: $selection)
                    .environmentObject(vm)
                    .frame(width: 320, height: 280)
                    .navigationTitle("Pick a symbol")
            }
            Image(systemName: selection)
                .font(.system(size: 34))
                .font(.title3)
                .padding()
        }
        .frame(width: 320)
        .frame(minHeight: 230)
    #endif
    #if os(iOS)
        NavigationView {
            VStack {
                Button("Select a symbol") {
                    isPresented.toggle()
                }
                Image(systemName: selection)
                    .font(.system(size: 34))
                    .sheet(isPresented: $isPresented, content: {
                        NavigationStack {
                            SFSymbolsPickerPanel(selection: $selection)
                                .environmentObject(vm)
                                .navigationTitle("Pick a symbol")
                        }
                    })
                    .padding()
            }
            .navigationTitle("SF Symbols Picker")
        }
    #endif
}
