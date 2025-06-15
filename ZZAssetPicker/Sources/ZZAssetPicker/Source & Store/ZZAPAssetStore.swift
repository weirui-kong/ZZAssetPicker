//
//  ZZAPAssetStore.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos

@objc public class ZZAPAssetStore: NSObject {
    private let fetchResult: PHFetchResult<PHAsset>?
    private let customAssets: [ZZAPAsset]?
    
    @objc public init(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
        self.customAssets = nil
    }
    
    @objc public init(customAssets: [ZZAPAsset]) {
        self.customAssets = customAssets
        self.fetchResult = nil
    }
    
    @objc public var count: Int {
        if let result = fetchResult { return result.count }
        if let array = customAssets { return array.count }
        return 0
    }
    
    @objc public func asset(at index: Int) -> ZZAPAsset {
        if let result = fetchResult {
            return ZZAPPHAsset(asset: result.object(at: index))
        }
        if let array = customAssets {
            return array[index]
        }
        fatalError("Index out of bounds")
    }
}
