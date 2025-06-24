//
//  ZZAssetPickerUIElementsConfiguration.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation

@objcMembers
public class ZZAssetPickerUIElementsConfiguration: NSObject {

    public var tabTypes: [ZZAPTabType] = []

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

    public init(tabTypes: [ZZAPTabType]) {
        self.tabTypes = tabTypes
        super.init()
    }

    @objc public init(tabTypes: NSArray) {
        super.init()
        self.tabTypes = tabTypes.compactMap {
            if let number = $0 as? NSNumber {
                return ZZAPTabType(rawValue: number.intValue)
            }
            return nil
        }
    }
}
