//
//  ZZAssetPickerUserInterfaceConfiguration.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation

@objc
public enum ZZAPMediaSubtypeBadgeOption: Int {
    case none      = 0
    case livePhoto = 1
    
    public static let all: Int = ZZAPMediaSubtypeBadgeOption.livePhoto.rawValue
    
    public func contains(option: ZZAPMediaSubtypeBadgeOption) -> Bool {
        return (self.rawValue & option.rawValue) != 0
    }
}

@objcMembers
public class ZZAssetPickerUserInterfaceConfiguration: NSObject {

    public var tabTypes: [ZZAPTabType] = []
    public var mediaSubtypeBadgeOption: ZZAPMediaSubtypeBadgeOption = .none

    // OC-bridge
    @objc public var __unsafe_tabTypes: NSArray {
        get { return tabTypes.map { NSNumber(value: $0.rawValue) } as NSArray }
        set {
            tabTypes = newValue.compactMap {
                if let number = $0 as? NSNumber {
                    return ZZAPTabType(rawValue: number.intValue)
                }
                return nil
            }
        }
    }

    public override init() {
        super.init()
    }

    public init(tabTypes: [ZZAPTabType], mediaSubtypeBadge: ZZAPMediaSubtypeBadgeOption) {
        self.tabTypes = tabTypes
        self.mediaSubtypeBadgeOption = mediaSubtypeBadge
        super.init()
    }

    @objc public init(tabTypes: NSArray, mediaSubtypeBadge: ZZAPMediaSubtypeBadgeOption) {
        super.init()
        self.tabTypes = tabTypes.compactMap {
            if let number = $0 as? NSNumber {
                return ZZAPTabType(rawValue: number.intValue)
            }
            return nil
        }
        self.mediaSubtypeBadgeOption = mediaSubtypeBadge
    }
}
