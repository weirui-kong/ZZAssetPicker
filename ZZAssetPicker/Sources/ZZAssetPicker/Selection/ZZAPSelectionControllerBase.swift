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
    @objc public private(set) var selectedAssets: [Int : ZZAPAsset] = [:]
    
    // MARK: - Tap Handling
    
    /// Optional handler called when a tap occurs on an asset
    /// - Parameters:
    ///   - asset: The PHAsset tapped
    ///   - indexPath: Optional indexPath of the asset in the collection view
    ///   - transitionContext: Optional transition context for animation/navigation
    @objc public func handleTap(on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?) {
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
    
    /// Optional handler called when a tap on badge occurs on an asset
    /// - Parameters:
    ///   - asset: The PHAsset tapped
    ///   - indexPath: Optional indexPath of the asset in the collection view
    ///   - transitionContext: Optional transition context for animation/navigation
    @MainActor
    @objc public func handleTapOnBadge(on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?) {
        switch selectionMode {
        case .none:
            print("Selection is disabled")
            
        case .single:
            if let currentIndex = selectedAssets.firstIndex(where: { $1.id == asset.id }) {
                selectedAssets.remove(at: currentIndex)
            } else {
                selectedAssets[1] = asset
            }
            
        case .multiple:
            if let currentIndex = selectedAssets.firstIndex(where: { $1.id == asset.id }) {
                let removedKey = selectedAssets[currentIndex].key
                selectedAssets.remove(at: currentIndex)
                let updatedAssets = selectedAssets.reduce(into: [Int: ZZAPAsset]()) { result, entry in
                    let newKey = entry.key > removedKey ? entry.key - 1 : entry.key
                    result[newKey] = entry.value
                }
                selectedAssets = updatedAssets
            } else {
                let nextIndex = selectedAssets.isEmpty ? 0 : (selectedAssets.keys.max()! + 1)
                selectedAssets[nextIndex] = asset
            }
        }
        self.notifySelectionChanged()
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
    
    // MARK: - Selection Change Listener
    
    /// Type alias for selection change listener closure
    /// Provides the updated array of selected assets
    public typealias SelectionChangeListener = ([Int : ZZAPAsset]) -> Void
    
    /// Dictionary to hold listeners identified by UUID strings
    /// Key: listener token (UUID string), Value: listener closure
    private var selectionChangeListeners: [String: SelectionChangeListener] = [:]
    
    /// Register a listener to be notified when selection changes
    /// - Parameter listener: Closure called with the current selected assets
    /// - Returns: A token string to be used for removing the listener
    @objc
    public func addSelectionChangeListener(_ listener: @escaping SelectionChangeListener) -> String {
        let id = UUID().uuidString
        selectionChangeListeners[id] = listener
        return id
    }
    
    /// Remove a previously registered selection change listener
    /// - Parameter token: The token returned by `addSelectionChangeListener`
    @objc
    public func removeSelectionChangeListener(token: String) {
        selectionChangeListeners.removeValue(forKey: token)
    }
    
    /// Notify all registered listeners about the current selection state
    private func notifySelectionChanged() {
        let currentSelection = selectedAssets
        for listener in selectionChangeListeners.values {
            listener(currentSelection)
        }
    }
}
