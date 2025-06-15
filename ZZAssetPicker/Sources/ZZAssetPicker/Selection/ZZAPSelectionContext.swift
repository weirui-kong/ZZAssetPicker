//
//  ZZAPSelectionContext.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos

/// Closure for defining asset tap behavior
public typealias ZZAPTapBehaviorHandler = (_ context: ZZAPSelectionContext) -> Void

@objc public class ZZAPSelectionContext: NSObject {
    /// The tapped asset
    @objc public let asset: PHAsset

    /// IndexPath if known (optional)
    @objc public let indexPath: IndexPath?

    /// Current selection status
    @objc public let isSelected: Bool

    /// Current selection mode (single/multiple)
    @objc public let selectionMode: ZZAPSelectionMode

    /// List of currently selected assets
    @objc public let selectedAssets: [PHAsset]

    /// Initialization
    @objc public init(
        asset: PHAsset,
        indexPath: IndexPath?,
        isSelected: Bool,
        selectionMode: ZZAPSelectionMode,
        selectedAssets: [PHAsset]
    ) {
        self.asset = asset
        self.indexPath = indexPath
        self.isSelected = isSelected
        self.selectionMode = selectionMode
        self.selectedAssets = selectedAssets
    }
}
