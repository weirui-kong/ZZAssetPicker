//
//  ZZAPSelectionControllerBase.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/14/25.
//

import Foundation
import Photos
import UIKit

@objc open class ZZAPSelectionControllerBase: NSObject, ZZAPSelectable {
    
    /// Optional validation manager to control asset selection validation
    public var validationManager: ZZAPAssetValidatorManager?
    
    /// Current selection mode (e.g., single or multiple)
    @objc public var selectionMode: ZZAPSelectionMode = .multiple
    
    /// Currently selected assets (read-only externally)
    @objc public private(set) var selectedAssets: [PHAsset] = []
    
    // MARK: - Tap Handling
    
    /// Called when user taps an asset.
    /// Constructs selection context and forwards to `didTapAsset`.
    /// - Parameters:
    ///   - asset: The tapped asset
    ///   - indexPath: Optional indexPath of the asset in collection view
    ///   - transitionContext: Optional context for navigation or animation
    public func handleTap(on asset: PHAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?) {
        let isSelected = selectedAssets.contains(asset)
        let selectionContext = ZZAPSelectionContext(
            asset: asset,
            indexPath: indexPath,
            isSelected: isSelected,
            selectionMode: selectionMode,
            selectedAssets: selectedAssets
        )
        
        didTapAsset(selectionContext: selectionContext, transitionContext: transitionContext)
    }
    
    /// Override point for subclasses to implement tap handling strategy.
    /// - Parameters:
    ///   - selectionContext: Context describing the tapped asset and selection state
    ///   - transitionContext: Optional context for navigation or animation
    @MainActor
    @objc open func didTapAsset(selectionContext: ZZAPSelectionContext?, transitionContext: ZZAPTransitionContext?) {
        // Subclass or user-defined closure should handle tap
    }
    
    // MARK: - Built-in Behaviors
    
    /// Toggle selection state of asset described by selectionContext.
    /// Subclasses can override to customize behavior.
    /// - Parameter selectionContext: Context of asset and current selection
    @MainActor
    @objc open func toggle(selectionContext: ZZAPSelectionContext) {
        // Subclass can override to implement toggle logic
    }
    
    /// Show preview for asset described by selectionContext.
    /// Subclasses can override to customize preview behavior.
    /// - Parameters:
    ///   - selectionContext: Context of asset and current selection
    ///   - transitionContext: Optional context for navigation or animation
    @MainActor
    @objc open func preview(selectionContext: ZZAPSelectionContext?, transitionContext: ZZAPTransitionContext?) {
        // Subclass can override to implement preview logic
    }
    
    /// Navigate to detail or other screens for the asset.
    /// Subclasses can override to customize navigation behavior.
    /// - Parameter selectionContext: Context of asset and current selection
    @MainActor
    @objc open func navigate(selectionContext: ZZAPSelectionContext) {
        // Subclass can override to implement navigation logic
    }
}
