//
//  ZZAPThumbnailImageQuality.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/5/25.
//

import Foundation
import UIKit

@MainActor
@objc
public enum ZZAPThumbnailImageQuality: Int {
    case low = 1     // Scale = 1.0
    case medium = 2  // Scale = 2.0
    case high = 3    // Scale = 3.0
    case device = 0  // Use UIScreen.main.scale

    public var scale: CGFloat {
        switch self {
        case .low: return 1.0
        case .medium: return 2.0
        case .high: return 3.0
        case .device: return UIScreen.main.scale
        }
    }

    public var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .device: return "Device"
        }
    }
}
