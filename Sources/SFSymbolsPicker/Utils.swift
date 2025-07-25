//
//  Utils.swift
//  SFSymbolsPicker
//
//  Created by wong on 7/25/25.
//

import Foundation

internal extension String {
    func localized() -> String {
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
    func localized(locale: Locale = Locale.current) -> String {
        let languagePart = locale.identifier.split(separator: "_").first.map(String.init) ?? ""
        guard let path = Bundle.module.path(forResource: languagePart, ofType: "lproj") else {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle.module, comment: "")
        }
        let languageBundle = Bundle(path: path)
        return NSLocalizedString(self, bundle: languageBundle ?? .module, comment: "")
    }
}
