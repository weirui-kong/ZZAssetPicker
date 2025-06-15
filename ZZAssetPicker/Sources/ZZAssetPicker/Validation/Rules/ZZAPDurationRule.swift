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
    public func validate(asset: PHAsset) -> Bool {
        guard asset.mediaType == .video else { return true }
        return asset.duration <= maxDuration
    }
    
    /// Provide failure info when validation fails.
    /// - Parameter asset: The failing asset.
    /// - Returns: Failure detail describing duration issue.
    public func failureInfo(for asset: PHAsset) -> ZZAPAssetValidationFailure? {
        guard !validate(asset: asset) else { return nil }
        return ZZAPAssetValidationFailure(
            code: "duration_too_long",
            message: "Video duration exceeds max allowed \(maxDuration) seconds.",
            extra: ["actualDuration": asset.duration]
        )
    }
}
