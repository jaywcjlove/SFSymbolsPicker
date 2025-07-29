//
//  SFSymbolsPickerModifier.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/30/25.
//

import SwiftUI

public struct SFSymbolsPickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selection: String
    let prompt: String
    let autoDismiss: Bool
    let panelSize: CGSize?
    let navigationTitle: String?
    
    @State private var vm: SFSymbolsPickerViewModel
    @State private var selectedSymbol: String = ""
    @State private var searchText = ""
    @Environment(\.locale) var locale
    
    public init(
        isPresented: Binding<Bool>,
        selection: Binding<String>,
        prompt: String = String("search"),
        autoDismiss: Bool = true,
        panelSize: CGSize? = nil,
        navigationTitle: String? = nil
    ) {
        self._isPresented = isPresented
        self._selection = selection
        self.prompt = prompt
        self.autoDismiss = autoDismiss
        self.panelSize = panelSize
        self.navigationTitle = navigationTitle
        
        // Create a new ViewModel instance to ensure each modifier has independent state
        let viewModel = SFSymbolsPickerViewModel(prompt: prompt, autoDismiss: autoDismiss)
        self._vm = State(initialValue: viewModel)
        self._selectedSymbol = State(initialValue: selection.wrappedValue)
    }
    
    public func body(content: Content) -> some View {
        content
#if os(macOS)
            .popover(isPresented: $isPresented) {
                SFSymbolsPickerPanel(selection: $selectedSymbol)
                    .environmentObject(vm)
                    .frame(
                        width: panelSize?.width ?? 316,
                        height: panelSize?.height ?? 260
                    )
            }
#endif
#if os(iOS)
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    SFSymbolsPickerPanel(selection: $selectedSymbol)
                        .environmentObject(vm)
                        .navigationTitle((navigationTitle ?? "select_a_symbol").localized(locale: locale))
                }
                .onAppear {
                    let newVM = SFSymbolsPickerViewModel(prompt: prompt, autoDismiss: autoDismiss)
                    vm = newVM
                }
            }
#endif
            .onAppear() {
                if selectedSymbol.isEmpty {
                    selectedSymbol = selection
                }
                vm.searchText = searchText
            }
            .onChange(of: isPresented, initial: false) { old, val in
                if isPresented == false {
                    selection = selectedSymbol
                    searchText = vm.searchText
                } else {
                    // When popover opens, restore previous search text and ensure icon data is available
                    selectedSymbol = selection
                    vm.searchText = searchText
                }
            }
            .onChange(of: selection, initial: false) { old, val in
                if old != val {
                    selectedSymbol = selection
                }
            }
    }
}

// MARK: - View Extension
public extension View {
    /// Add SF Symbols picker modifier
    /// - Parameters:
    ///   - isPresented: Binding to control picker visibility
    ///   - selection: Binding for selected symbol
    ///   - prompt: Search field placeholder text
    ///   - autoDismiss: Whether to auto-dismiss after symbol selection
    ///   - panelSize: Panel size (macOS only)
    ///   - navigationTitle: Navigation title (iOS only)
    /// - Returns: View with applied modifier
    func sfSymbolsPicker(
        isPresented: Binding<Bool>,
        selection: Binding<String>,
        prompt: String = String("search"),
        autoDismiss: Bool = true,
        panelSize: CGSize? = nil,
        navigationTitle: String? = nil
    ) -> some View {
        self.modifier(
            SFSymbolsPickerModifier(
                isPresented: isPresented,
                selection: selection,
                prompt: prompt,
                autoDismiss: autoDismiss,
                panelSize: panelSize,
                navigationTitle: navigationTitle
            )
        )
    }
}

// MARK: - Preview
#Preview("SF Symbols Picker Modifier") {
    @Previewable @State var isPresented1 = false
    @Previewable @State var isPresented2 = false
    @Previewable @State var selection1 = "star.bubble"
    @Previewable @State var selection2 = "heart.fill"
    
    VStack(spacing: 30) {
        // First button
        VStack {
            Button("Button 1 - Picker") {
                isPresented1 = true
            }
            .sfSymbolsPicker(
                isPresented: $isPresented1,
                selection: $selection1,
                prompt: "Search symbols...",
                autoDismiss: true,
                navigationTitle: "Choose Symbol 1"
            )
            
            HStack {
                Text("Selection 1:")
                Image(systemName: selection1)
                Text(selection1)
            }
            .font(.caption)
        }
        
        Divider()
        
        // Second button
        VStack {
            Button("Button 2 - Picker") {
                isPresented2 = true
            }
            .sfSymbolsPicker(
                isPresented: $isPresented2,
                selection: $selection2,
                prompt: "Find icons...",
                autoDismiss: false,
                navigationTitle: "Choose Symbol 2"
            )
            
            HStack {
                Text("Selection 2:")
                Image(systemName: selection2)
                Text(selection2)
            }
            .font(.caption)
        }
    }
    .padding()
}
