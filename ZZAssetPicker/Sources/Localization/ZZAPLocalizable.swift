//
//  ZZAPLocalizable.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/12/25.
//

public protocol ZZAPLocalizable {
    var localizationKey: String { get }
    var localizedString: String { get }
}

public extension ZZAPLocalizable {
    var localizedString: String {
        return ZZAPLocalizationManager.shared.localizedString(forKey: localizationKey)
    }
}
