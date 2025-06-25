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

    public var minimumSize: CGSize = .zero
    public var maximumSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

    public var minimumDuration: TimeInterval = 0
    public var maximumDuration: TimeInterval = .infinity

    public var requireFaces: Bool = false
    public var requireQrCodes: Bool = false

    public override init() {
        super.init()
        validate()
    }

    private func validate() {
        if minimumSize.width > maximumSize.width || minimumSize.height > maximumSize.height {
            fatalError("Invalid size configuration: minimumSize must be smaller than or equal to maximumSize")
        }

        if minimumDuration > maximumDuration {
            fatalError("Invalid duration configuration: minimumDuration must be less than or equal to maximumDuration")
        }

        if maximumSelection <= 0 {
            fatalError("maximumSelection must be greater than 0")
        }
    }
}
