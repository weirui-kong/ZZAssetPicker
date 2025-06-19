//
//  ZZAPSelectable.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos
import UIKit

// MARK: - Selection Delegate

@objc
public protocol ZZAPSelectableDelegate: AnyObject {
    
    /// Called when the selection has changed.
    /// - Parameters:
    ///   - selectable: The selection controller that triggered the change.
    ///   - sender: The sender who triggers this event.
    ///   - selectedAssets: The current selected assets, ordered by selection index.
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : ZZAPAsset])
    
    /// Called when a selection attempt fails due to validation.
    /// - Parameters:
    ///   - selectable: The selection controller that triggered the failure.
    ///   - sender: The sender who triggers this event.
    ///   - asset: The asset that failed validation.
    ///   - failure: The failure reason/info.
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didFailToSelect asset: ZZAPAsset, dueTo failure: ZZAPAssetValidationFailure)
}

// MARK: - Selectable Protocol

@objc
public protocol ZZAPSelectable: AnyObject {
    
    // MARK: - Selection State

    /// Currently selected assets (read-only externally).
    /// Key (index) starts from 1.
    @objc var selectedAssets: [Int : ZZAPAsset] { get }

    /// Ordered array of selected assets sorted by selection index.
    /// Note: Gaps in index will be skipped in result.
    @objc optional var orderedSelectedAssets: [ZZAPAsset] { get }

    /// Current selection mode (single/multiple).
    @objc var selectionMode: ZZAPSelectionMode { get set }

    /// Cursor pointing to the next available selection slot (optional).
    /// Useful under `multipleSparse` mode.
    @objc optional var targetingSelectionCursor: Int { get set }

    /// Optional max selection count.
    @objc optional var maximumSelection: Int { get set }

    // MARK: - Validation

    /// Optional validation manager; overrides router if set.
    @objc optional var validationManager: ZZAPAssetValidatorManager? { get set }

    /// Optional validation router used when manager is not set.
    @objc optional var validationRouter: ZZAPAssetSlotValidationRouter? { get set }

    // MARK: - Event Handling

    /// Handle tap gesture on an asset.
    /// - Parameters:
    ///   - sender: Source of interaction.
    ///   - asset: Target asset.
    ///   - indexPath: IndexPath in collection view.
    ///   - transitionContext: Optional transition animation context.
    @MainActor
    @objc optional func handleTap(from sender: AnyObject, on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?)

    /// Handle tap on badge.
    /// - Parameters:
    ///   - sender: Source of interaction.
    ///   - asset: Target asset.
    ///   - indexPath: IndexPath in collection view.
    ///   - transitionContext: Optional transition animation context.
    @MainActor
    @objc optional func handleTapOnBadge(from sender: AnyObject, on asset: ZZAPAsset, at indexPath: IndexPath?, transitionContext: ZZAPTransitionContext?)

    // MARK: - Delegate Management

    /// Add a delegate to receive selection events.
    @objc optional func addSelectableDelegate(_ delegate: ZZAPSelectableDelegate)

    /// Remove a delegate.
    @objc optional func removeSelectableDelegate(_ delegate: ZZAPSelectableDelegate)
}
