//
//  ZZAPDurationRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Comparison types for video duration validation.
@objc public enum ZZAPDurationRuleType: Int {
    case greaterThan    // duration > x
    case lessThan       // duration < x
    case withinRange    // min <= duration <= max
}

/// Rule that validates video duration based on comparison type.
/// Always passes for non-video assets.
@objc public class ZZAPDurationRule: NSObject, ZZAPAssetValidationRule {
    
    private let ruleType: ZZAPDurationRuleType
    private let minDuration: TimeInterval
    private let maxDuration: TimeInterval
    
    @objc public static func greaterThan(duration: TimeInterval) -> ZZAPDurationRule {
        .init(type: .greaterThan, min: duration, max: .infinity)
    }
    
    @objc public static func lessThan(duration: TimeInterval) -> ZZAPDurationRule {
        .init(type: .greaterThan, min: .zero, max: duration)
    }
    
    @objc public static func within(min: TimeInterval, max: TimeInterval) -> ZZAPDurationRule {
        .init(type: .withinRange, min: min, max: max)
    }
    /// Initialize a rule with a range.
    /// - Parameters:
    ///   - type: Rule type (should be `.withinRange`)
    ///   - min: Minimum duration.
    ///   - max: Maximum duration.
    private init(type: ZZAPDurationRuleType, min: TimeInterval, max: TimeInterval) {
        self.ruleType = type
        self.minDuration = min
        self.maxDuration = max
    }
    
    /// Validate asset duration.
    /// - Parameter asset: Asset to validate.
    /// - Returns: Validation failure if invalid; nil if valid or not a video.
    public func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure? {
        guard asset.mediaType == .video || asset.mediaType == .audio else {
            return nil
        }
        
        let actual = asset.duration
        
        switch ruleType {
        case .greaterThan:
            if actual <= minDuration {
                return ZZAPAssetValidationFailure(
                    code: "0x2101",
                    message: ZZAPLocalized("zzap_validation_rule_duration_too_short", minDuration, actual),
                    extra: ["duration": actual]
                )
            }
            
        case .lessThan:
            if actual >= maxDuration {
                return ZZAPAssetValidationFailure(
                    code: "0x2102",
                    message: ZZAPLocalized("zzap_validation_rule_duration_too_long", maxDuration, actual),
                    extra: ["duration": actual]
                )
            }
            
        case .withinRange:
            if actual < minDuration || actual > maxDuration {
                return ZZAPAssetValidationFailure(
                    code: "0x2103",
                    message: ZZAPLocalized("zzap_validation_rule_duration_out_of_range", minDuration, maxDuration, actual),
                    extra: ["duration": actual]
                )
            }
        }
        
        return nil
    }
}
