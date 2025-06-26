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
        self.notifyDidStartSelectionValidatoin(from: sender, on: asset)
        // Max limit
        if selectedAssets.count >= maximumSelection {
            notifySelectionEnd(from: sender, on: asset, failure: ZZAPAssetValidationFailure(
                code: "0x0000",
                message: "Maximum selection reached."
            ))
            return
        }
        
        // Validation check
        if let validator = validationManager {
            validator.progressiveValidate(asset: asset) { [weak self] in
                return self?.validationShouldStop(from: self, on: asset) ?? false
            } progress: { [weak self] current, total in
                self?.notifyDidValidate(from: self, on: asset, current: current, total: total)
            } completion: { [weak self] failure in
                if let failure = failure {
                    DispatchQueue.main.async {
                        self?.notifySelectionEnd(from: sender, on: asset, failure: failure)
                    }
                } else {
                    self?.selectedAssets[index] = asset
                    self?.targetingSelectionCursor = (self?.selectedAssets.keys.max() ?? 0) + 1
                    self?.notifySelectionEnd(from: sender, on: asset, failure: nil)
                    self?.notifySelectionChanged(from: sender)
                }
            }
        }
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
        NotificationCenter.default.post(
            name: .ZZAPSelectionDidChange,
            object: self,
            userInfo: [
                "sender": sender as Any,
                "selectedAssets": selectedAssets
            ]
        )
    }

    @MainActor
    internal func notifySelectionEnd(from sender: AnyObject?, on asset: ZZAPAsset, failure: ZZAPAssetValidationFailure?) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didEndSelectionValidatoin: asset, mayFail: failure)
        }
        NotificationCenter.default.post(
            name: .ZZAPValidationDidEnd,
            object: self,
            userInfo: [
                "sender": sender as Any,
                "asset": asset,
                "failure": failure as Any
            ]
        )
    }

    @MainActor
    internal func notifyDidStartSelectionValidatoin(from sender: AnyObject?, on asset: ZZAPAsset) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didStartSelectionValidatoin: asset)
        }
        NotificationCenter.default.post(
            name: .ZZAPValidationDidStart,
            object: self,
            userInfo: [
                "sender": sender as Any,
                "asset": asset
            ]
        )
    }

    @MainActor
    internal func notifyDidValidate(from sender: AnyObject?, on asset: ZZAPAsset, current: Int, total: Int) {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, didValidate: asset, current: current, total: total)
        }
        NotificationCenter.default.post(
            name: .ZZAPValidationProgress,
            object: self,
            userInfo: [
                "sender": sender as Any,
                "asset": asset,
                "current": current,
                "total": total
            ]
        )
    }

    @MainActor
    internal func validationShouldStop(from sender: AnyObject?, on asset: ZZAPAsset) -> Bool {
        var shouldStop = false
        for delegate in delegates.allObjects {
            if let stop = (delegate as? ZZAPSelectableDelegate)?
                .selectable?(self, from: sender, shouldStopValidating: asset),
               stop {
                shouldStop = true
            }
        }
        NotificationCenter.default.post(
            name: .ZZAPValidationShouldStop,
            object: self,
            userInfo: [
                "sender": sender as Any,
                "asset": asset,
                "shouldStop": shouldStop
            ]
        )
        return shouldStop
    }
}
