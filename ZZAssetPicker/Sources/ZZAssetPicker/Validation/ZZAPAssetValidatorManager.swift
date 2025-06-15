//
//  ZZAPAssetValidatorManager.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Aggregates multiple validation rules and validates an asset against all of them.
/// Returns false on first failure.
@objc public class ZZAPAssetValidatorManager: NSObject {
    /// Array of validation rules.
    @objc public let rules: [ZZAPAssetValidationRule]
    
    /// Initialize with a list of validation rules.
    /// - Parameter rules: Array of rules to be used.
    @objc public init(rules: [ZZAPAssetValidationRule]) {
        self.rules = rules
    }
    
    /// Validate an asset by checking all rules.
    /// - Parameter asset: The PHAsset to validate.
    /// - Returns: True if all rules pass, false otherwise.
    @objc public func validate(asset: PHAsset) -> Bool {
        for rule in rules {
            if !rule.validate(asset: asset) {
                return false
            }
        }
        return true
    }
    
    /// Collect all failure infos from rules for a given asset.
    /// - Parameter asset: The PHAsset to check.
    /// - Returns: Array of failure details for all failing rules.
    @objc public func failureInfos(for asset: PHAsset) -> [ZZAPAssetValidationFailure] {
        return rules.compactMap { $0.failureInfo?(for: asset) }
    }
}
