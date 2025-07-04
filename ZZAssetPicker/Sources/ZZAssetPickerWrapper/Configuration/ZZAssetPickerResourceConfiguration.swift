//
//  ZZAssetPickerResourceConfiguration.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/25/25.
//

import Foundation

@objcMembers
public class ZZAssetPickerResourceConfiguration: NSObject {

    public var thumbnailQuality: ZZAPThumbnailImageQuality = .device

    public override init() {
        super.init()
    }

}
