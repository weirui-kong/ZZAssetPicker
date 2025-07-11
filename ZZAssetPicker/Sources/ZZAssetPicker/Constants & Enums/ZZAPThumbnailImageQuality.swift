//
//  ZZAPThumbnailImageQuality.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/5/25.
//

import Foundation
import UIKit

@objc
public enum ZZAPThumbnailImageQuality: Int, ZZAPLocalizable {
    case low = 1     // Scale = 1.0
    case medium = 2  // Scale = 2.0
    case high = 3    // Scale = 3.0
    case device = 0  // Use UIScreen.main.scale

    @MainActor
    public var scale: CGFloat {
        switch self {
        case .low: return 1.0
        case .medium: return 2.0
        case .high: return 3.0
        case .device: return UIScreen.main.scale
        }
    }

    public var localizationKey: String {
        switch self {
        case .low: return "zzap_thumbnail_image_quality_low"
        case .medium: return "zzap_thumbnail_image_quality_medium"
        case .high: return "zzap_thumbnail_image_quality_high"
        case .device: return "zzap_thumbnail_image_quality_device_scale"
        }
    }
}
