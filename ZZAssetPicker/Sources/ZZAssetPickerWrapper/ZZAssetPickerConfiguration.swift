//
//  ZZAssetPickerConfiguration.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation

@objcMembers
public class ZZAssetPickerConfiguration: NSObject {
    public var selectionConfig: ZZAssetPickerSelectionConfiguration = .init()
    public var userInterfaceConfig: ZZAssetPickerUserInterfaceConfiguration = .init()
}
