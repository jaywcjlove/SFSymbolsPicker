// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

class SFSymbolsPickerVM: ObservableObject {
    @Published var size: CGSize = .init(width: 316, height: 260)
    @Published var navigationTitle: String = "select_a_symbol"
}

public extension SFSymbolsPicker where LabelView == EmptyView {
    init(
        selection: Binding<String>,
        prompt: String = String("search"),
        autoDismiss: Bool = true
    ) {
        self._selection = selection
        self.label = nil
        self.vm = SFSymbolsPickerViewModel(prompt: prompt, autoDismiss: autoDismiss)
    }
}

public struct SFSymbolsPicker<LabelView>: View where LabelView : View  {
    @Environment(\.locale) var locale
    @ObservedObject var view: SFSymbolsPickerVM = .init()
    @Binding var selection: String
    @State private var selectedSymbol: String = ""
    @ObservedObject var vm: SFSymbolsPickerViewModel
    @State private var searchText = ""
    @State var isPresented: Bool = false
    @ViewBuilder let label: LabelView?
    public init(
        selection: Binding<String>,
        prompt: String = String("search"),
        autoDismiss: Bool = true,
        labelView: (() -> LabelView)? = nil
    ) {
        self._selection = selection
        self.label = labelView?()
        self.vm = SFSymbolsPickerViewModel(prompt: prompt, autoDismiss: autoDismiss)
    }
    public var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            if let label {
                label
            } else {
                Text("select_a_symbol".localized(locale: locale))
            }
        })
#if os(macOS)
        .popover(isPresented: $isPresented) {
            SFSymbolsPickerPanel(selection: $selectedSymbol)
                .environmentObject(vm)
                .frame(width: view.size.width, height: view.size.height)
        }
#endif
#if os(iOS)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                SFSymbolsPickerPanel(selection: $selectedSymbol)
                    .environmentObject(vm)
                    .navigationTitle(view.navigationTitle.localized(locale: locale))
            }
        }
#endif
        .onChange(of: isPresented, initial: false, { old, val in
            if isPresented == false {
                selection = selectedSymbol
            }
        })
    }
    public func panelSize(_ size: CGSize) -> some View {
        view.size = size
        return self
    }
    public func navigationTitle(_ title: String) -> some View {
        view.navigationTitle = title
        return self
    }
}

#Preview {
    @Previewable @State var selection: String = "star.bubble"
    VStack(spacing: 23) {
        SFSymbolsPicker(selection: $selection, prompt: String(localized: "Search symbols..."))
        SFSymbolsPicker(selection: $selection, autoDismiss: false)
        SFSymbolsPicker(selection: $selection, autoDismiss: false) {
            Text("选择符号")
        }
        SFSymbolsPicker(selection: $selection)
            .panelSize(.init(width: 230, height: 100))
        Image(systemName: selection)
            .font(.system(size: 34))
            .font(.title3)
            .padding()
    }
    .frame(width: 320, height: 330)
}
