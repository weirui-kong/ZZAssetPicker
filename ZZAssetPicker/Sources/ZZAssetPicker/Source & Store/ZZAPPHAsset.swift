//
//  ZZAPPHAsset.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos
import UIKit

@objc
public class ZZAPPHAsset: NSObject, ZZAPAsset {
    
    
    private let asset: PHAsset
    private var requestID: PHImageRequestID?

    public init(asset: PHAsset) {
        self.asset = asset
    }

    public var id: String {
        asset.localIdentifier
    }

    public var sourceType: ZZAPAssetSourceType {
        .photoLibrary
    }

    public var mediaType: PHAssetMediaType {
        asset.mediaType
    }
    
    public var mediaSubtypes: PHAssetMediaSubtype {
        asset.mediaSubtypes
    }
    
    public var pixelWidth: Int {
        asset.pixelWidth
    }
    
    public var pixelHeight: Int {
        asset.pixelHeight
    }
    
    public var duration: TimeInterval {
        asset.duration
    }
    
    public var creationDate: Date? {
        asset.creationDate
    }
    
    public var modificationDate: Date? {
        asset.modificationDate
    }
    
    public func requestImage(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> Int32 {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast

        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
//            let delay = Double.random(in: 0...0.5)
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                completion(image)
//            }
            completion(image)
        }

        return requestID!
    }


    public func cancelImageRequest(requestID: Int32) {
        PHImageManager.default().cancelImageRequest(requestID)
    }
}

@objc
public extension PHPhotoLibrary {
    static var currentAuthorizationStatus: PHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }
}
