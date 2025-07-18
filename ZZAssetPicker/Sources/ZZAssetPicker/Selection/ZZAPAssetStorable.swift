//
//  ZZAPAssetStorable.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/19/25.
//

import Foundation
import Photos
import UIKit

@objc
public protocol ZZAPAssetStorable: AnyObject {
    
    @objc var collections: [PHAssetCollection]? { get set }

    @objc var currentCollection: PHAssetCollection? { get set }

    @objc optional func updateCollection(_ collection: PHAssetCollection?)

    @objc optional func reloadCollections()
}
