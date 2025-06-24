//
//  ZZAssetPickerSelectionConfiguration.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation

@objcMembers
public class ZZAssetPickerSelectionConfiguration: NSObject {
    public var selectionMode: ZZAPSelectionMode = .multipleCompact
    public var maximumSelection: Int = 99
    
    public override init() {
        super.init()
    }
    
    init(selectionMode: ZZAPSelectionMode, maximumSelection: Int) {
        self.selectionMode = selectionMode
        self.maximumSelection = maximumSelection
    }
}
