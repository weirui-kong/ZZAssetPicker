//
//  ZZAPAssetValidationRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Protocol that each asset validation rule must conform to.
/// Defines how to validate an asset and optionally provide failure info.
@objc public protocol ZZAPAssetValidationRule: AnyObject {
    /// Validates the given asset.
    /// - Parameter asset: The PHAsset to validate.
    /// - Returns: True if asset passes validation, false otherwise.
    func validate(asset: PHAsset) -> Bool
    
    /// Optionally provide failure info if validation fails.
    /// - Parameter asset: The PHAsset that failed validation.
    /// - Returns: Validation failure details or nil if no failure.
    @objc optional func failureInfo(for asset: PHAsset) -> ZZAPAssetValidationFailure?
}
