//
//  SFSymbolsPickerSampleView.swift
//  SFSymbolsPicker
//
//  
//

import SwiftUI

public struct SFSymbolsPickerSampleView: View {
    @State private var selectedSymbol: String = "star.fill"
    @State private var isPickerPresented = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: selectedSymbol)
                        .font(.system(size: 56))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 96, height: 96)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))

                    Text(selectedSymbol)
                        .font(.headline)
                        .textSelection(.enabled)
                }

                VStack(spacing: 12) {
                    Button("Open Symbols Picker") {
                        isPickerPresented = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Choose Another Symbol") {
                        isPickerPresented = true
                    }
                    .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("How to test")
                        .font(.headline)

                    Text("1. Pick a few symbols to build the Recent section.")
                    Text("2. Tap the star overlay on symbols to add or remove Favorites.")
                    Text("3. Reopen the picker to confirm both sections persist.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Symbols Picker Demo")
            .sfSymbolsPicker(
                isPresented: $isPickerPresented,
                selection: $selectedSymbol,
                prompt: "Search symbols...",
                autoDismiss: false,
                panelSize: .init(width: 360, height: 420),
                navigationTitle: "Pick a Symbol"
            )
        }
    }
}

#Preview("Symbols Picker Demo") {
    SFSymbolsPickerSampleView()
}
