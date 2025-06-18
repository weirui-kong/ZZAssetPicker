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
    
    init(validationManager: ZZAPAssetValidatorManager? = nil, selectionMode: ZZAPSelectionMode, maximumSelection: Int) {
        self.validationManager = validationManager
        self.selectionMode = selectionMode
        self.maximumSelection = maximumSelection
        self.targetingSelectionCursor = 0
        self.selectedAssets = [:]
    }
    
    /// Optional validation manager to control asset selection validation
    public var validationManager: ZZAPAssetValidatorManager?
    
    /// Current selection mode (e.g., single or multiple)
    @objc public var selectionMode: ZZAPSelectionMode = .multipleCompact
    
    @objc public var maximumSelection: Int = 0
    @objc public var targetingSelectionCursor: Int = 0
    
    /// Currently selected assets (read-only externally)
    @objc public private(set) var selectedAssets: [Int : ZZAPAsset] = [:]
    @objc public var orderedSelectedAssets: [ZZAPAsset] {
        // Return assets sorted by their index
        // Gaps in indices will result in a shorter array than the max index + 1
        return selectedAssets.sorted { $0.key < $1.key }.map { $0.value }
    }
    // MARK: - Tap Handling
    
    @objc public func handleTap(from sender: UIViewController, on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?) {
        let isSelected = selectedAssets.values.contains { $0.id == asset.id }
        let selectionContext = ZZAPSelectionContext(
            asset: asset,
            indexPath: indexPath,
            isSelected: isSelected,
            selectionMode: selectionMode,
            selectedAssets: selectedAssets
        )
        
        didTapAsset(selectionContext: selectionContext, transitionContext: transitionContext)
    }
    
    @MainActor
    @objc public func handleTapOnBadge(from sender: UIViewController, on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?) {
        switch selectionMode {
        case .none:
            print("Selection is disabled")
            
        case .single:
            if let currentIndex = selectedAssets.firstIndex(where: { $1.id == asset.id }) {
                selectedAssets.remove(at: currentIndex)
            } else {
                selectedAssets[1] = asset
            }
        case .multipleCompact:
            if let currentIndex = selectedAssets.first(where: { $1.id == asset.id })?.key {
                // Deselect
                selectedAssets.removeValue(forKey: currentIndex)

                // Shift all following items forward
                let maxIndex = selectedAssets.keys.max() ?? 0
                if currentIndex < maxIndex {
                    for index in (currentIndex+1)...maxIndex {
                        if let movedAsset = selectedAssets[index] {
                            selectedAssets[index - 1] = movedAsset
                            selectedAssets.removeValue(forKey: index)
                        }
                    }
                }

                // Update cursor to the next slot
                targetingSelectionCursor = (selectedAssets.keys.max() ?? 0) + 1

            } else {
                // Select and append to the end
                guard selectedAssets.count < maximumSelection else {
                    notifySelectionFailed(
                        from: sender,
                        on: asset,
                        failure: ZZAPAssetValidationFailure(
                            code: "0x01",
                            message: "Maximum selection reached."
                        )
                    )
                    return
                }

                targetingSelectionCursor = (selectedAssets.keys.max() ?? 0) + 1
                selectedAssets[targetingSelectionCursor] = asset
            }

            
        case .multipleSparse:
            // TODO: To be verified...
            // If the asset is already selected, remove it
            if let currentIndex = selectedAssets.firstIndex(where: { $1.id == asset.id }) {
                selectedAssets.remove(at: currentIndex)
            } else {
                // Try to add the asset
                
                // If the cursor is out of range, move it to the first available slot
                if targetingSelectionCursor <= 0 || targetingSelectionCursor >= maximumSelection {
                    targetingSelectionCursor = (0..<maximumSelection).first { selectedAssets[$0] == nil } ?? targetingSelectionCursor
                }
                
                // Add the asset to current cursor
                selectedAssets[targetingSelectionCursor] = asset
                
                // Find another slot
                if let next = ((targetingSelectionCursor + 1)..<maximumSelection).first(where: { selectedAssets[$0] == nil }) {
                    targetingSelectionCursor = next
                } else if let wrapAround = (0..<maximumSelection).first(where: { selectedAssets[$0] == nil }) {
                    targetingSelectionCursor = wrapAround
                } else {
                    // No empty slot, keep cursor as is
                }
            }
        }
        self.notifySelectionChanged(from: sender)
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
    
    // MARK: - Selection Delegates
    
    /// Delegate collection (weak references)
    private let delegates = NSHashTable<AnyObject>.weakObjects()
    
    /// Add a delegate listener
    @objc public func addSelectableDelegate(_ delegate: ZZAPSelectableDelegate) {
        delegates.add(delegate)
    }
    
    /// Remove a previously added delegate
    @objc public func removeSelectableDelegate(_ delegate: ZZAPSelectableDelegate) {
        delegates.remove(delegate)
    }
    
    /// Notify all delegates that the selection changed
    @MainActor
    internal func notifySelectionChanged(from sender: UIViewController) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didChangeSelection: selectedAssets)
        }
    }
    
    /// Notify all delegates that selection failed
    @MainActor
    internal func notifySelectionFailed(from sender: UIViewController, on asset: ZZAPAsset, failure: ZZAPAssetValidationFailure) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didFailToSelect: asset, dueTo: failure)
        }
    }
}
