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
        self.prompt = prompt
        self.autoDismiss = autoDismiss
        self.label = nil
    }
}

public struct SFSymbolsPicker<LabelView>: View where LabelView : View  {
    @Environment(\.locale) var locale
    @ObservedObject var view: SFSymbolsPickerVM = .init()
    @Binding var selection: String
    @State var isPresented: Bool = false
    @State var autoDismiss: Bool = false
    @State var prompt: String = String("search")
    @ViewBuilder let label: LabelView?
    public init(
        selection: Binding<String>,
        prompt: String = String("search"),
        autoDismiss: Bool = true,
        labelView: (() -> LabelView)? = nil
    ) {
        self._selection = selection
        self.prompt = prompt
        self.autoDismiss = autoDismiss
        self.label = labelView?()
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
        .sfSymbolsPicker(
            isPresented: $isPresented,
            selection: $selection,
            prompt: "Search symbols...",
            autoDismiss: autoDismiss,
            panelSize: view.size,
            navigationTitle: view.navigationTitle
        )
    }
    public func panelSize(_ size: CGSize) -> SFSymbolsPicker {
        view.size = size
        return self as SFSymbolsPicker
    }
    public func navigationTitle(_ title: String) -> SFSymbolsPicker {
        view.navigationTitle = title
        return self as SFSymbolsPicker
    }
}


extension Notification.Name {
    public static let showSymbolsPickerPopover = Notification.Name("com.sfsymbolepicker.showSymbolsPickerPopover")
}

#Preview {
    @Previewable @State var selection: String = "star.bubble"
    @Previewable @State var isPresented: Bool = false
    
    VStack(spacing: 23) {
        // 使用 SFSymbolsPicker 组件
        SFSymbolsPicker(selection: $selection, prompt: String(localized: "Search symbols..."))
        SFSymbolsPicker(selection: $selection, autoDismiss: false)
        SFSymbolsPicker(selection: $selection, autoDismiss: false) {
            Text("选择符号")
        }
        SFSymbolsPicker(selection: $selection)
            .panelSize(.init(width: 230, height: 100))
            
        Divider()
        
        Image(systemName: selection)
            .font(.system(size: 34))
            .font(.title3)
            .padding()
    }
    .frame(width: 320, height: 400)
}
