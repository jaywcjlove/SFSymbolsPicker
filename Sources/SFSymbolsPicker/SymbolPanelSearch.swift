//
//  PickerPanelSearch.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//

import SwiftUI

struct SymbolPanelSearch: View {
    @Environment(\.locale) var locale
    @Binding var value: String
    @FocusState private var isTextFieldFocused: Bool
    var prompt: String
    var body: some View {
        ZStack(alignment: .leading) {
            TextField(prompt.localized(locale: locale), text: $value)
                .focused($isTextFieldFocused)
                .textFieldStyle(.plain)
                .padding(.vertical, 6)
                .padding(.leading, 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isTextFieldFocused ? Color.accentColor.opacity(0.67) : Color.clear, lineWidth: 2)
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                    .padding(.leading, 6)
                Spacer()
                if value.isEmpty == false {
                    Button(action: {
                        value = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    })
                    .buttonStyle(.plain)
                }
            }
            .padding(.trailing, 6)
        }
        .frame(alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
    }
}
