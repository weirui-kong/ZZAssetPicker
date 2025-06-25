//
//  ZZAPResolutionRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/21/25.
//

import Foundation
import UIKit

private enum ZZAPResolutionRuleType {
    case greaterThan(CGFloat, CGFloat)
    case lessThan(CGFloat, CGFloat)
    case withinRange(minWidth: CGFloat, minHeight: CGFloat, maxWidth: CGFloat, maxHeight: CGFloat)
    case widthGreaterThan(CGFloat)
    case widthLessThan(CGFloat)
    case widthInRange(min: CGFloat, max: CGFloat)
    case heightGreaterThan(CGFloat)
    case heightLessThan(CGFloat)
    case heightInRange(min: CGFloat, max: CGFloat)
}

@objc public class ZZAPResolutionRule: NSObject, ZZAPAssetValidationRule {
    private let ruleType: ZZAPResolutionRuleType

    private init(type: ZZAPResolutionRuleType) {
        self.ruleType = type
    }

    // MARK: - Public Initializers

    @objc public static func greaterThan(width: CGFloat, height: CGFloat) -> ZZAPResolutionRule {
        .init(type: .greaterThan(width, height))
    }

    @objc public static func lessThan(width: CGFloat, height: CGFloat) -> ZZAPResolutionRule {
        .init(type: .lessThan(width, height))
    }

    @objc public static func within(minWidth: CGFloat, minHeight: CGFloat, maxWidth: CGFloat, maxHeight: CGFloat) -> ZZAPResolutionRule {
        .init(type: .withinRange(minWidth: minWidth, minHeight: minHeight, maxWidth: maxWidth, maxHeight: maxHeight))
    }

    @objc public static func widthGreaterThan(_ minWidth: CGFloat) -> ZZAPResolutionRule {
        .init(type: .widthGreaterThan(minWidth))
    }

    @objc public static func widthLessThan(_ maxWidth: CGFloat) -> ZZAPResolutionRule {
        .init(type: .widthLessThan(maxWidth))
    }

    @objc public static func widthInRange(min: CGFloat, max: CGFloat) -> ZZAPResolutionRule {
        .init(type: .widthInRange(min: min, max: max))
    }

    @objc public static func heightGreaterThan(_ minHeight: CGFloat) -> ZZAPResolutionRule {
        .init(type: .heightGreaterThan(minHeight))
    }

    @objc public static func heightLessThan(_ maxHeight: CGFloat) -> ZZAPResolutionRule {
        .init(type: .heightLessThan(maxHeight))
    }

    @objc public static func heightInRange(min: CGFloat, max: CGFloat) -> ZZAPResolutionRule {
        .init(type: .heightInRange(min: min, max: max))
    }

    // MARK: - Validation Logic

    public func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure? {
        guard asset.pixelWidth > 0, asset.pixelHeight > 0 else {
            return ZZAPAssetValidationFailure(code: "0x2000", message: "Pixel size unavailable or invalid")
        }

        let size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))

        switch ruleType {
        case let .greaterThan(w, h):
            if size.width < w || size.height < h {
                return ZZAPAssetValidationFailure(
                    code: "0x2001",
                    message: "Resolution too small: requires > \(w)x\(h), got \(Int(size.width))x\(Int(size.height))",
                    extra: ["width": size.width, "height": size.height]
                )
            }

        case let .lessThan(w, h):
            if size.width > w || size.height > h {
                return ZZAPAssetValidationFailure(
                    code: "0x2002",
                    message: "Resolution too large: requires < \(w)x\(h), got \(Int(size.width))x\(Int(size.height))",
                    extra: ["width": size.width, "height": size.height]
                )
            }

        case let .withinRange(minW, minH, maxW, maxH):
            if size.width < minW || size.width > maxW || size.height < minH || size.height > maxH {
                return ZZAPAssetValidationFailure(
                    code: "0x2003",
                    message: "Resolution out of allowed range: requires \(minW)–\(maxW)x\(minH)–\(maxH), got \(Int(size.width))x\(Int(size.height))",
                    extra: ["width": size.width, "height": size.height]
                )
            }

        case let .widthGreaterThan(minW):
            if size.width < minW {
                return ZZAPAssetValidationFailure(
                    code: "0x2004",
                    message: "Width too small: requires > \(minW), got \(Int(size.width))",
                    extra: ["width": size.width]
                )
            }

        case let .widthLessThan(maxW):
            if size.width > maxW {
                return ZZAPAssetValidationFailure(
                    code: "0x2005",
                    message: "Width too large: requires < \(maxW), got \(Int(size.width))",
                    extra: ["width": size.width]
                )
            }

        case let .widthInRange(min, max):
            if size.width < min || size.width > max {
                return ZZAPAssetValidationFailure(
                    code: "0x2006",
                    message: "Width not in range: requires \(min)–\(max), got \(Int(size.width))",
                    extra: ["width": size.width]
                )
            }

        case let .heightGreaterThan(minH):
            if size.height < minH {
                return ZZAPAssetValidationFailure(
                    code: "0x2007",
                    message: "Height too small: requires > \(minH), got \(Int(size.height))",
                    extra: ["height": size.height]
                )
            }

        case let .heightLessThan(maxH):
            if size.height > maxH {
                return ZZAPAssetValidationFailure(
                    code: "0x2008",
                    message: "Height too large: requires < \(maxH), got \(Int(size.height))",
                    extra: ["height": size.height]
                )
            }

        case let .heightInRange(min, max):
            if size.height < min || size.height > max {
                return ZZAPAssetValidationFailure(
                    code: "0x2009",
                    message: "Height not in range: requires \(min)–\(max), got \(Int(size.height))",
                    extra: ["height": size.height]
                )
            }
        }

        return nil
    }


}
