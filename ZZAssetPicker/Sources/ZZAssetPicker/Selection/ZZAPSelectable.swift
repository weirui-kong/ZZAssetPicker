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

    @objc var selectedAssets: [Int : ZZAPAsset] { get }

    @objc optional var orderedSelectedAssets: [ZZAPAsset] { get }

    @objc var selectionMode: ZZAPSelectionMode { get set }

    @objc optional var targetingSelectionCursor: Int { get set }

    @objc optional var maximumSelection: Int { get set }

    // MARK: - Validation

    @objc optional var validationManager: ZZAPAssetValidatorManager? { get set }

    @objc optional var validationRouter: ZZAPAssetSlotValidationRouter? { get set }

    // MARK: - Selection Actions

    @MainActor
    @objc optional func addAsset(_ sender: AnyObject?, _ asset: ZZAPAsset)

    @MainActor
    @objc optional func addAsset(_ sender: AnyObject?, _ asset: ZZAPAsset, at index: Int)

    @MainActor
    @objc optional func removeAsset(_ sender: AnyObject?, at index: Int)

    @MainActor
    @objc optional func index(_ sender: AnyObject?, for asset: ZZAPAsset) -> Int

    // MARK: - Delegate Management

    @objc optional func addSelectableDelegate(_ delegate: ZZAPSelectableDelegate)

    @objc optional func removeSelectableDelegate(_ delegate: ZZAPSelectableDelegate)
}
