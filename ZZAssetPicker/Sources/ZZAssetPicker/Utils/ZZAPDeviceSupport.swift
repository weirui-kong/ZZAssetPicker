//
//  ZZAPDeviceSupport.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import UIKit
import Foundation

@objcMembers
public class ZZAPDeviceSupport: NSObject {

    /// Current device model identifier, e.g., "iPhone14,5", "iPad11,2", "Mac14,1"
    private static let machine: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }()

    /// Parses the device type ("iPhone", "iPad", "Mac") and major version (e.g., 14 in "iPhone14,5")
    private static func deviceInfo() -> (type: String, major: Int)? {
        let prefixes = ["iPhone", "iPad", "Mac"]

        for prefix in prefixes {
            if machine.hasPrefix(prefix) {
                let versionPart = machine.dropFirst(prefix.count)
                let majorStr = versionPart.split(separator: ",").first ?? "0"
                if let major = Int(majorStr) {
                    return (prefix, major)
                }
            }
        }

        return nil
    }

    /// Generic feature check.
    ///
    /// - Parameters:
    ///   - deviceMinMajor: A dictionary defining the minimum required major version for each device type.
    ///   - defaultValue: The fallback result if the device type is not listed or can't be identified.
    /// - Returns: `true` if the current device meets the requirement, or `defaultValue` otherwise.
    public static func isSupported(deviceMinMajor: [String: Int], default defaultValue: Bool) -> Bool {
        guard let info = deviceInfo() else {
            return defaultValue
        }

        if let required = deviceMinMajor[info.type] {
            return info.major >= required
        } else {
            return defaultValue
        }
    }

    // MARK: - Actual Feature Support Flags

    /// Whether the device supports blur effects (e.g., UIVisualEffectView).
    /// - iPhone 14+ and iPad 11+ are supported.
    public static var supportsBlurEffect: Bool {
        return isSupported(deviceMinMajor: [
            "iPhone": 14,
            "iPad": 11
        ], default: true)
    }

    /// Whether the device supports badge shadows.
    public static var supportsBadgeShadow: Bool {
        return isSupported(deviceMinMajor: [
            "iPhone": 128,
            "iPad": 128
        ], default: false)
    }
}
