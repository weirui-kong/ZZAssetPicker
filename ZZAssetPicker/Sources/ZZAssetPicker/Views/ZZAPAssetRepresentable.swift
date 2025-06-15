//
//  ZZAPAssetRepresentable.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos
import UIKit

/// Base protocol that all asset-based cells conform to.
@MainActor
@objc public protocol ZZAPAssetRepresentable: AnyObject {
    
    static var reuseIdentifier: String { get }
    
    /// The asset this cell represents
    var asset: PHAsset? { get set }

    /// Thumbnail image (optional, for transition animation)
    var thumbnailImage: UIImage? { get }

    /// The view to use as animation source
    var contentFrameInWindow: CGRect { get }

    /// The index in current selected sources
    var selectedIndex: Int { get set }
    
    /// The selection mode that applies. Default is none
    var selectionMode: ZZAPSelectionMode { get set }
    
    /// Configure the cell with given asset
    func configure(with asset: PHAsset)
}
