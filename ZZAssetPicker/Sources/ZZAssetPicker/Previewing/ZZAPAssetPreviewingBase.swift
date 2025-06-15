//
//  ZZAPAssetPreviewingBase.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import UIKit
import Photos

@objc public class ZZAPAssetPreviewingBase: NSObject, @preconcurrency ZZAPAssetPreviewing {
    
    /// Preview the given asset by presenting an alert with its info
    /// - Parameters:
    ///   - asset: The PHAsset to preview
    ///   - thumbnail: Optional thumbnail image for the asset
    ///   - allAssets: Array of all assets in the current context
    ///   - fromViewController: The view controller from which to present the preview
    ///   - sourceFrame: The frame of the source view (for animation or positioning, if needed)
    @MainActor
    @objc public func preview(
        asset: PHAsset,
        thumbnail: UIImage?,
        allAssets: [PHAsset],
        fromViewController: UIViewController,
        sourceFrame: CGRect
    ) {
        let alert = UIAlertController(
            title: "Previewing Asset",
            message: """
                ID: \(asset.localIdentifier)
                Duration: \(asset.duration)
                Total in list: \(allAssets.count)
                Thumbnail exists: \(thumbnail != nil)
                """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        fromViewController.present(alert, animated: true)
    }
}
