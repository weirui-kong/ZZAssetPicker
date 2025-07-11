//
//  ZZAPDefaultLocalizationProvider.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import Foundation

public class ZZAPDefaultLocalizationProvider: ZZAPLocalizationProvider {
    
    private var cache: [String: [String: String]] = [:] // language → [key: string]

    public init() {}

    public func localizedString(forKey key: String, language: String?) -> String? {
        let language = language ?? "default"
        
        if cache[language] == nil {
            let actualLanguage = loadLanguage(language)
            if actualLanguage != language, let dict = cache[actualLanguage] {
                cache[language] = dict
            }
        }
        
        return cache[language]?[key]
    }

    @discardableResult
    private func loadLanguage(_ language: String) -> String {
        var actualLanguage = language
        var url = Bundle.module.url(forResource: language, withExtension: "json")

        if url == nil {
            actualLanguage = "default"
            url = Bundle.module.url(forResource: "default", withExtension: "json")
        }

        guard let finalURL = url,
              let data = try? Data(contentsOf: finalURL),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return language
        }

        cache[actualLanguage] = dict
        return actualLanguage
    }
}

