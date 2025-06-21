//
//  ZZAPAsset.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import UIKit
import Photos

@objc
public protocol ZZAPAsset: AnyObject {
    @objc var id: String { get }
    @objc var sourceType: ZZAPAssetSourceType { get }
    @objc var mediaType: PHAssetMediaType { get }
    @objc optional var mediaSubtypes: PHAssetMediaSubtype { get }

    /// The pixel width of the asset (like PHAsset.pixelWidth)
    @objc var pixelWidth: Int { get }

    /// The pixel height of the asset (like PHAsset.pixelHeight)
    @objc var pixelHeight: Int { get }
    
    /// The duration of the asset in seconds (for video/audio), 0 for images
    @objc var duration: TimeInterval { get }
    
    /// A user-friendly creation date (optional)
    @objc var creationDate: Date? { get }
    
    /// A user-friendly modification date (optional)
    @objc var modificationDate: Date? { get }
    
    /// A  image temporarily will be stored in memory that can be used without calling fetch frequently (optional)
    /// You are responsible for managing its lifecycle
    @objc optional var cacheImage: Bool { get set }
    
    /// Request image with target size and callback
    @objc func requestImage(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> Int32
    
    /// Cancel previous image request if any
    @objc func cancelImageRequest(requestID: Int32)
    
    /// Request AVAsset for video playback (optional, can be no-op for images)
    @objc optional func requestAVAsset(completion: @escaping (AVAsset?) -> Void) -> Int32
    
    /// Cancel AVAsset request if any
    @objc optional func cancelAVAssetRequest(requestID: Int32)
    
    @objc func isEqual(to other: ZZAPAsset) -> Bool

}

