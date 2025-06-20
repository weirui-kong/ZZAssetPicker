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
    
    public init(validationManager: ZZAPAssetValidatorManager? = nil, selectionMode: ZZAPSelectionMode, maximumSelection: Int) {
        self.validationManager = validationManager
        self.selectionMode = selectionMode
        self.maximumSelection = maximumSelection
        self.targetingSelectionCursor = 0
        self.selectedAssets = [:]
    }

    public var validationManager: ZZAPAssetValidatorManager?
    
    @objc public var selectionMode: ZZAPSelectionMode = .multipleCompact
    @objc public var maximumSelection: Int = 0
    @objc public var targetingSelectionCursor: Int = 0
    
    @objc public private(set) var selectedAssets: [Int : ZZAPAsset] = [:]

    @objc public var orderedSelectedAssets: [ZZAPAsset] {
        return selectedAssets.sorted { $0.key < $1.key }.map { $0.value }
    }

    // MARK: - Selection Operations

    @objc public func addAsset(_ sender: AnyObject? = nil, _ asset: ZZAPAsset) {
        let nextIndex = (selectedAssets.keys.max() ?? 0) + 1
        addAsset(sender, asset, at: nextIndex)
    }

    @objc public func addAsset(_ sender: AnyObject? = nil, _ asset: ZZAPAsset, at index: Int) {
        // Max limit
        if selectedAssets.count >= maximumSelection {
            notifySelectionFailed(from: sender, on: asset, failure: ZZAPAssetValidationFailure(
                code: "0x01",
                message: "Maximum selection reached."
            ))
            return
        }

        // Validation check
        if let validator = validationManager, let failure = validator.validate(asset: asset) {
            notifySelectionFailed(from: sender, on: asset, failure: failure)
            return
        }

        selectedAssets[index] = asset
        targetingSelectionCursor = (selectedAssets.keys.max() ?? 0) + 1
        notifySelectionChanged(from: sender)
    }

    @objc public func removeAsset(_ sender: AnyObject? = nil, at index: Int) {
        guard let asset = selectedAssets[index] else { return }

        selectedAssets.removeValue(forKey: index)
        switch selectionMode {
        case .none: break
        case .single: break
        case .multipleCompact:
            let keysToUpdate = selectedAssets.keys.filter { $0 > index }
            for oldKey in keysToUpdate.sorted() {
                let newKey = oldKey - 1
                selectedAssets[newKey] = selectedAssets[oldKey]
                selectedAssets.removeValue(forKey: oldKey)
            }
        case .multipleSparse: break
        }
        targetingSelectionCursor = (selectedAssets.keys.max() ?? 0) + 1
        notifySelectionChanged(from: sender)
    }

    @objc public func index(_ sender: AnyObject? = nil, for asset: ZZAPAsset) -> Int {
        return selectedAssets.first(where: { $0.value.id == asset.id })?.key ?? NSNotFound
    }

    // MARK: - Delegate Management

    private let delegates = NSHashTable<AnyObject>.weakObjects()

    @objc public func addSelectableDelegate(_ delegate: ZZAPSelectableDelegate) {
        delegates.add(delegate)
    }

    @objc public func removeSelectableDelegate(_ delegate: ZZAPSelectableDelegate) {
        delegates.remove(delegate)
    }

    @MainActor
    internal func notifySelectionChanged(from sender: AnyObject?) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didChangeSelection: selectedAssets)
        }
    }

    @MainActor
    internal func notifySelectionFailed(from sender: AnyObject?, on asset: ZZAPAsset, failure: ZZAPAssetValidationFailure) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didFailToSelect: asset, dueTo: failure)
        }
    }
}
