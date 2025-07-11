//
//  ZZAPTabType.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation

/// Enum representing different types of media tabs in the album UI.
/// Defines which media types are shown or selectable in a given tab.
@objc public enum ZZAPTabType: Int, ZZAPLocalizable {
    /// Shows all media types (videos, photos,  etc.)
    case all = 0
    
    /// Shows only videos.
    case videos = 1
    
    /// Shows only photos (including live photos).
    case photos = 2
    
    /// Shows only Live Photos.
    case livePhotos = 3
    
}

extension ZZAPTabType {
    /// Returns a localized string representation for each tab type.
    public var localizationKey: String {
        switch self {
        case .all:
            return ZZAPLocalized("zzap_tab_type_all")
        case .videos:
            return ZZAPLocalized("zzap_tab_type_videos")
        case .photos:
            return ZZAPLocalized("zzap_tab_type_photos")
        case .livePhotos:
            return ZZAPLocalized("zzap_tab_type_livePhotos")
        }
    }
}
