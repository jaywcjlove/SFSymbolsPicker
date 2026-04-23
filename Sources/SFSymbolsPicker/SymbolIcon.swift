//
//  SymbolIcon.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//

import SwiftUI

struct SymbolIcon: View {
    let symbolName: String
    @Binding var selection: String
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    private let size: CGFloat = 42
    private let cornerRadius: CGFloat = 8
    @State private var isPressed: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selection = symbolName
                }
            } label: {
                Image(systemName: symbolName)
                    .font(.system(size: 24, weight: .regular))
                    .frame(width: size, height: size)
                    .background(tileBackground)
                    .foregroundColor(selection == symbolName ? .accentColor : .primary)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                    .contentShape(Rectangle())
            }
            .buttonStyle(SymbolButtonStyle(isPressed: $isPressed))
            .contentShape(Rectangle())

            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isFavorite ? .yellow : .secondary)
                    .padding(5)
                    .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: -6)
            .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        }
    }

    private var tileBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFavorite ? Color.yellow.opacity(0.35) : Color.clear, lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        if selection == symbolName {
            return Color.accentColor.opacity(0.15)
        }

        if isFavorite {
            return Color.yellow.opacity(0.12)
        }

        return .clear
    }
}

private struct SymbolButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

#Preview {
    @Previewable @State var saturation: String = "star.bubble"
    VStack {
        SymbolIcon(
            symbolName: "snowflake",
            selection: $saturation,
            isFavorite: true,
            onFavoriteToggle: {}
        )
        SymbolIcon(
            symbolName: "fan.badge.automatic",
            selection: $saturation,
            isFavorite: false,
            onFavoriteToggle: {}
        )
    }
    .frame(width: 320, height: 230)
}
