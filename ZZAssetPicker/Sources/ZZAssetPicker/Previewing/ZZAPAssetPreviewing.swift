//
//  ZZAPAssetPreviewing.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import UIKit
import Photos

/// A protocol that defines the interface for asset preview presentation.
/// Designed for flexibility and animation-capable transitions.
@objc
public protocol ZZAPAssetPreviewing: AnyObject {
    /// Present a preview of a specific asset within a list context.
    ///
    /// - Parameters:
    ///   - asset: The selected `PHAsset` to preview.
    ///   - thumbnail: Optional thumbnail image of the asset.
    ///   - allAssets: The full list of assets (e.g. for swiping).
    ///   - fromViewController: The view controller initiating the preview.
    ///   - sourceFrame: Optional frame of the tapped cell in screen coordinates (for transition animation).
    @objc func preview(
        asset: PHAsset,
        thumbnail: UIImage?,
        allAssets: [PHAsset],
        fromViewController: UIViewController,
        sourceFrame: CGRect
    )
}
