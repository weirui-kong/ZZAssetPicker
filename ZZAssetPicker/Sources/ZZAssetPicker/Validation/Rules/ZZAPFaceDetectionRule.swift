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
        guard asset.mediaType == .image else { return nil }

        if Thread.isMainThread {
            assertionFailure("Can't call validate synchronously on main thread")
            return nil
        }

        let semaphore = DispatchSemaphore(value: 0)
        var image: UIImage?

        asset.requestImage(targetSize: CGSize(width: 512, height: 512)) { result in
            image = result
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 30)

        guard let cgImage = image?.cgImage else {
            return ZZAPAssetValidationFailure(
                code: "0x2201",
                message: ZZAPLocalized("zzap_validation_rule_face_image_unavailable")
            )
        }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            let hasFace = (request.results?.count ?? 0) > 0
            if requireFace && !hasFace {
                return ZZAPAssetValidationFailure(
                    code: "0x2202",
                    message: ZZAPLocalized("zzap_validation_rule_face_not_detected")
                )
            }
        } catch {
            return ZZAPAssetValidationFailure(
                code: "0x2203",
                message: ZZAPLocalized("zzap_validation_rule_face_detection_failed"),
                extra: ["error": error.localizedDescription]
            )
        }

        return nil
    }
}
