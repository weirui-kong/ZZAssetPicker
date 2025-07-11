//
//  ZZAPLocalized.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import Foundation

@inlinable
public func ZZAPLocalized(_ key: String) -> String {
    return ZZAPLocalizationManager.shared.localizedString(forKey: key)
}

@inlinable
public func ZZAPLocalized(_ key: String, _ args: CVarArg...) -> String {
    let format = ZZAPLocalized(key)
    return String(format: format, arguments: args)
}
