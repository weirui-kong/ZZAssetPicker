//
//  ZZAPAssetSlotValidationRouter.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Manages validation for different 'slots' (indices), allowing
/// per-slot validator managers or fallback to a default validator.
/// Supports slots with no validation configured.
@objc public class ZZAPAssetSlotValidationRouter: NSObject {
    /// Dictionary mapping slot index to its validator manager.
    private var managers: [Int: ZZAPAssetValidatorManager] = [:]
    
    /// Default validator manager used if slot-specific manager is not set.
    @objc public var defaultManager: ZZAPAssetValidatorManager?
    
    /// Sets validator manager for a specific slot.
    /// Passing nil removes any existing manager for that slot.
    /// - Parameters:
    ///   - manager: Validator manager or nil.
    ///   - slot: The slot index.
    @objc public func setValidatorManager(_ manager: ZZAPAssetValidatorManager?, forSlot slot: Int) {
        if let m = manager {
            managers[slot] = m
        } else {
            managers.removeValue(forKey: slot)
        }
    }
    
    /// Retrieves the validator manager for a given slot,
    /// falling back to defaultManager if none set.
    /// - Parameter slot: Slot index.
    /// - Returns: Validator manager or nil if none configured.
    private func manager(for slot: Int) -> ZZAPAssetValidatorManager? {
        return managers[slot] ?? defaultManager
    }
    
    /// Validate an asset for a specific slot.
    /// If no validator configured, returns true (allowed).
    /// - Parameters:
    ///   - asset: Asset to validate.
    ///   - slot: Slot index.
    /// - Returns: True if asset passes validation or no rules set.
    @objc public func validate(asset: ZZAPAsset, forSlot slot: Int) -> ZZAPAssetValidationFailure? {
        return manager(for: slot)?.validate(asset: asset)
    }
    
    /// Get validation failure details for an asset and slot.
    /// Returns empty array if no rules or all passed.
    /// - Parameters:
    ///   - asset: Asset to check.
    ///   - slot: Slot index.
    /// - Returns: Array of validation failure details.
    @objc public func failureInfos(for asset: ZZAPAsset, slot: Int) -> [ZZAPAssetValidationFailure] {
        return manager(for: slot)?.failureInfos(for: asset) ?? []
    }
}
