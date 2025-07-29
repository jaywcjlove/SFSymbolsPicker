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
        self._vm = State(initialValue: SFSymbolsPickerViewModel(prompt: prompt, autoDismiss: autoDismiss))
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
            }
#endif
            .onAppear() {
                selectedSymbol = selection
                vm.searchText = searchText
            }
            .onChange(of: isPresented, initial: false) { old, val in
                if isPresented == false {
                    selection = selectedSymbol
                    searchText = vm.searchText
                } else {
                    // 当弹窗打开时，恢复之前的搜索文本
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
    /// 添加 SF Symbols 选择器装饰器
    /// - Parameters:
    ///   - isPresented: 控制选择器显示/隐藏的绑定
    ///   - selection: 选中符号的绑定
    ///   - prompt: 搜索框提示文本
    ///   - autoDismiss: 选择符号后是否自动关闭
    ///   - panelSize: 面板大小 (仅 macOS)
    ///   - navigationTitle: 导航标题 (仅 iOS)
    /// - Returns: 应用了装饰器的视图
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
    @Previewable @State var isPresented3 = false
    @Previewable @State var selection1 = "star.bubble"
    @Previewable @State var selection2 = "heart.fill"
    @Previewable @State var selection3 = "gear"
    
    VStack(spacing: 20) {
        // 第一个按钮
        Button("Button 1 - Picker") {
            isPresented1 = true
        }
        .sfSymbolsPicker(
            isPresented: $isPresented1,
            selection: $selection1,
            prompt: "Search symbols...",
            autoDismiss: true,
            panelSize: CGSize(width: 350, height: 300),
            navigationTitle: "Choose Symbol 1"
        )
        
        // 第二个按钮
        Button("Button 2 - Picker") {
            isPresented2 = true
        }
        .sfSymbolsPicker(
            isPresented: $isPresented2,
            selection: $selection2,
            prompt: "Find icons...",
            autoDismiss: false,
            panelSize: CGSize(width: 400, height: 350),
            navigationTitle: "Choose Symbol 2"
        )
        
        // 第三个示例：图标点击触发
        HStack {
            Text("Click icon:")
            Image(systemName: selection3)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .onTapGesture {
                    isPresented3 = true
                }
                .sfSymbolsPicker(
                    isPresented: $isPresented3,
                    selection: $selection3,
                    prompt: "Select new icon...",
                    autoDismiss: true
                )
        }
        
        Divider()
        
        // 显示选中的符号
        VStack(spacing: 10) {
            HStack {
                Text("Selection 1:")
                Image(systemName: selection1)
                Text(selection1)
            }
            HStack {
                Text("Selection 2:")
                Image(systemName: selection2)
                Text(selection2)
            }
            HStack {
                Text("Selection 3:")
                Image(systemName: selection3)
                Text(selection3)
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .padding()
}
