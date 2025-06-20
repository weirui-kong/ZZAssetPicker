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
    /// - Returns: Non-nil if asset passes validation, false otherwise.
    @objc func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure?
}
