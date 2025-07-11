//
//  ZZAPLocalizationProvider.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

import Foundation

@objc public protocol ZZAPLocalizationProvider {
    func localizedString(forKey key: String, language: String?) -> String?
}
