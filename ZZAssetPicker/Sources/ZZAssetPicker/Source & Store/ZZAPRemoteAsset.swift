//
//  ZZAPRemoteAsset.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/15/25.
//

import Foundation
import Photos
import UIKit

@objc
public class ZZAPRemoteAsset: NSObject, ZZAPAsset {
    public func isEqual(to other: any ZZAPAsset) -> Bool {
        id == other.id
    }
    
    // MARK: - Properties
    
    @objc public var pixelWidth: Int = 0
    @objc public var pixelHeight: Int = 0
    @objc public var duration: TimeInterval = 0
    @objc public var creationDate: Date? = nil
    @objc public var modificationDate: Date? = nil
    
    @objc public var cacheToMemory: Bool = false
    
    private let imageLock = NSLock()
    private var _cachedImage: UIImage?
    
    private var cachedImage: UIImage? {
        get {
            imageLock.lock()
            defer { imageLock.unlock() }
            return _cachedImage
        }
        set {
            imageLock.lock()
            _cachedImage = newValue
            imageLock.unlock()
        }
    }
    
    @objc private let url: URL
    @objc private var task: URLSessionDataTask?
    
    // MARK: - Init
    
    @objc public init(remoteURL: URL) {
        self.url = remoteURL
        super.init()
    }
    
    deinit {
        cachedImage = nil
        task?.cancel()
    }
    
    // MARK: - ZZAPAsset Protocol
    
    @objc public var id: String {
        url.absoluteString
    }
    
    @objc public var sourceType: ZZAPAssetSourceType {
        .remote
    }
    
    @objc public var mediaType: PHAssetMediaType {
        return .image
    }
    
    @objc public func requestImage(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) -> Int32 {
        if let cached = cachedImage {
            let imageCopy = cached.cgImage.map { UIImage(cgImage: $0) } ?? cached
            completion(imageCopy)
            return -1
        }
        
        task?.cancel()
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data, let image = UIImage(data: data) {
                self.pixelWidth = Int(image.size.width)
                self.pixelHeight = Int(image.size.height)
                if self.cacheToMemory {
                    self.cachedImage = image
                }
                completion(image)
            } else {
                completion(nil)
            }
        }
        task?.resume()
        return -1
    }
    
    @objc public func cancelImageRequest(requestID: Int32) {
        task?.cancel()
        task = nil
    }
}
