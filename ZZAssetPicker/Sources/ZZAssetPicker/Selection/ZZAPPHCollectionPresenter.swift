//
//  ZZAPPHCollectionPresenter.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 7/19/25.
//

import Foundation
import Photos
import UIKit

@objcMembers
public class ZZAPPHCollectionPresenter: NSObject, ZZAPCollectionPresenter {
    private(set) public var collections: [PHAssetCollection] = [] {
        didSet {
            notifyCollectionsUpdate()
        }
    }
    public var currentCollection: PHAssetCollection? {
        didSet {
            notifyCurrentCollectionUpdate()
        }
    }
    private let delegates = NSHashTable<AnyObject>.weakObjects()

    public override init() {
        super.init()
    }

    private var didFetchQuickDefaultCollection = false
    public func reloadCollections() {
        if !didFetchQuickDefaultCollection {
            fetchQuickDefaultCollection()
            didFetchQuickDefaultCollection = true
        }
        fetchSystemCollections()
    }

    public func updateCollection(_ collection: PHAssetCollection?) {
        self.currentCollection = collection
    }

    public func addCollectionDelegate(_ delegate: ZZAPCollectionPresenterDelegate) {
        delegates.add(delegate)
    }
    public func removeCollectionDelegate(_ delegate: ZZAPCollectionPresenterDelegate) {
        delegates.remove(delegate)
    }
    
    private func notifyCollectionsUpdate() {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPCollectionPresenterDelegate)?.collectionPresenter?(self, didUpdateCollections: collections)
        }
    }
    
    private func notifyCurrentCollectionUpdate() {
        for delegate in delegates.allObjects {
            (delegate as? ZZAPCollectionPresenterDelegate)?.collectionPresenter?(self, didUpdateCurrentCollection: currentCollection)
        }
    }
    
    // MARK: - Fetch System Collections
    private func fetchQuickDefaultCollection() {
        // assetCollectionType = .smartAlbum (2), subtype = 209
        // Which is almost equal to `all photos`
        let quickAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: PHAssetCollectionSubtype(rawValue: 209) ?? .any, options: nil)
        var defaultCollection: PHAssetCollection? = nil
        quickAlbums.enumerateObjects { (collection, _, stop) in
            defaultCollection = collection
            stop.pointee = true
        }

        if let defaultCollection = defaultCollection {
            updateCollection(defaultCollection)
        }
    }

    private func fetchSystemCollections() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var collections: [PHAssetCollection] = []
            
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            smartAlbums.enumerateObjects { (collection, _, _) in
                collections.append(collection)
            }
            
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            userAlbums.enumerateObjects { (collection, _, _) in
                collections.append(collection)
            }
            
            DispatchQueue.main.async {
                self.collections = collections
                let maxCollection = collections.max(by: { (lhs, rhs) in
                    PHAsset.fetchAssets(in: lhs, options: nil).count < PHAsset.fetchAssets(in: rhs, options: nil).count
                })
                if let maxCollection = maxCollection, self.currentCollection == nil {
                    self.updateCollection(maxCollection)
                }
            }
        }
    }
}
