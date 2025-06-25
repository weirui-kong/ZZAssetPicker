//
//  ZZAPFaceDetectionRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/26/25.
//

import Foundation
import Photos
import Vision
import UIKit

@objc public class ZZAPFaceDetectionRule: NSObject, ZZAPAssetValidationRule {

    private let requireFace: Bool

    @objc public init(requireFace: Bool = true) {
        self.requireFace = requireFace
    }

    public func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure? {
        // Only check image assets
        guard asset.mediaType == .image else { return nil }

        let semaphore = DispatchSemaphore(value: 0)
        var validationFailure: ZZAPAssetValidationFailure?

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        asset.requestImage(targetSize: CGSize(width: 512, height: 512)) { image in
            defer { semaphore.signal() }

            guard let cgImage = image?.cgImage else {
                validationFailure = ZZAPAssetValidationFailure(
                    code: "0x2201",
                    message: "Unable to load image for face detection"
                )
                return
            }

            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
                let foundFace = (request.results?.count ?? 0) > 0
                if self.requireFace && !foundFace {
                    validationFailure = ZZAPAssetValidationFailure(
                        code: "0x2202",
                        message: "No face detected in photo"
                    )
                }
            } catch {
                validationFailure = ZZAPAssetValidationFailure(
                    code: "0x2203",
                    message: "Face detection failed",
                    extra: ["error": error.localizedDescription]
                )
            }
        }

        _ = semaphore.wait(timeout: .now() + 2)

        return validationFailure
    }
}
