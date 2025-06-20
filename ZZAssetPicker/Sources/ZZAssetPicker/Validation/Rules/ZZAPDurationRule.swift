//
//  ZZAPDurationRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Rule that checks if video asset duration is within max duration.
/// Always passes for non-video assets.
@objc public class ZZAPDurationRule: NSObject, ZZAPAssetValidationRule {
    /// Maximum allowed duration in seconds.
    private let maxDuration: TimeInterval
    
    /// Initialize with maximum duration.
    /// - Parameter maxDuration: Maximum allowed duration in seconds.
    @objc public init(maxDuration: TimeInterval) {
        self.maxDuration = maxDuration
    }
    
    /// Validate asset duration.
    /// - Parameter asset: Asset to validate.
    /// - Returns: True if duration <= maxDuration or asset is not video.
    public func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure? {
        guard asset.mediaType == .video else {
            return nil
        }
        guard asset.duration <= maxDuration else {
            return ZZAPAssetValidationFailure(code: "0x2100", message: "Video too long", extra: nil)

        }
        return nil
    }
}
