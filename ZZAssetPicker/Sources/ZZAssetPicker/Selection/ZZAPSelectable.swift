//
//  ZZAPSelectable.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos

@objc
public protocol ZZAPSelectable: AnyObject {
    
    /// Optional validation manager; if provided, it overrides the validation router
    @objc optional var validationManager: ZZAPAssetValidatorManager? { get set }
    
    /// Optional validation router used if validationManager is not set
    @objc optional var validationRouter: ZZAPAssetSlotValidationRouter? { get set }
    
    /// Current selection mode (single or multiple)
    @objc var selectionMode: ZZAPSelectionMode { get set }
    
    /// Optional handler called when a tap occurs on an asset
    /// - Parameters:
    ///   - asset: The PHAsset tapped
    ///   - indexPath: Optional indexPath of the asset in the collection view
    ///   - transitionContext: Optional transition context for animation/navigation
    @MainActor
    @objc optional func handleTap(on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?)
}
