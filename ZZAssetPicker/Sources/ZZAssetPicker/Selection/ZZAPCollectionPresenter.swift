//
//  ZZAPCollectionPresenter.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/19/25.
//

import Foundation
import Photos
import UIKit

@MainActor
@objc public protocol ZZAPCollectionPresenterDelegate: AnyObject {
    @objc optional func collectionPresenter(_ presenter: ZZAPCollectionPresenter, didUpdateCollections collections: [PHAssetCollection])
    @objc optional func collectionPresenter(_ presenter: ZZAPCollectionPresenter, didUpdateCurrentCollection collection: PHAssetCollection?)
}

@MainActor
@objc public protocol ZZAPCollectionPresenter: AnyObject {
    @objc var collections: [PHAssetCollection] { get }
    @objc var currentCollection: PHAssetCollection? { get set }
    @objc func reloadCollections()
    @objc func updateCollection(_ collection: PHAssetCollection?)
    @objc optional func addCollectionDelegate(_ delegate: ZZAPCollectionPresenterDelegate)
    @objc optional func removeCollectionDelegate(_ delegate: ZZAPCollectionPresenterDelegate)
} 
 