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
    
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didStartSelectionValidatoin asset: ZZAPAsset)
    
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didEndSelectionValidatoin asset: ZZAPAsset, mayFail failure: ZZAPAssetValidationFailure?)
    
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didValidate asset: ZZAPAsset, current: Int, total: Int)
    
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, shouldStopValidating asset: ZZAPAsset) -> Bool
    
    @MainActor
    @objc optional func selectable(_ selectable: ZZAPSelectable, from sender: AnyObject?, didChangeSelection selectedAssets: [Int : ZZAPAsset])
    
    
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
