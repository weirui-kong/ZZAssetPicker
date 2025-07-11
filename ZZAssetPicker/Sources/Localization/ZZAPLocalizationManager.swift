//
//  ZZAPLocalizationManager.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import Foundation

@objcMembers
public class ZZAPLocalizationManager: NSObject {
    
    public static let shared = ZZAPLocalizationManager()
    
    public var currentLanguage: String = Locale.preferredLanguages.first ?? "en"

    public var provider: ZZAPLocalizationProvider?

    private let defaultProvider = ZZAPDefaultLocalizationProvider()

    public func localizedString(forKey key: String) -> String {
        let source = provider ?? defaultProvider
        return source.localizedString(forKey: key, language: currentLanguage) ?? key
    }
}

extension ZZAPLocalizationManager: @unchecked Sendable {}
