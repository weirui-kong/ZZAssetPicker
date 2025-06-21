//
//  ZZAPLocalAsset.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos
import UIKit

@objc
public class ZZAPLocalAsset: NSObject, ZZAPAsset {
    public func isEqual(to other: any ZZAPAsset) -> Bool {
        id == other.id
    }
    
    @objc private let url: URL

    @objc public init(fileURL: URL) {
        self.url = fileURL
    }

    @objc public var id: String {
        url.path
    }

    @objc public var sourceType: ZZAPAssetSourceType {
        .local
    }

    @objc public var mediaType: PHAssetMediaType {
        return .image
    }
    
    @objc public var pixelWidth: Int = 0
    
    @objc public var pixelHeight: Int = 0
    
    @objc public var duration: TimeInterval = 0
    
    @objc public var creationDate: Date?
    
    @objc public var modificationDate: Date?
    
    @objc public func requestImage(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> Int32 {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: self.url),
               let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        return -1
    }
    
    @objc public func cancelImageRequest(requestID: Int32) {
        
    }
}
