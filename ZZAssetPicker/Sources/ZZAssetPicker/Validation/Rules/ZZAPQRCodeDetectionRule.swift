//
//  ZZAPQRCodeDetectionRule.swift
//  ZZAssetPicker
//
//  Created by 孔维锐 on 6/26/25.
//

import Foundation
import Photos
import Vision
import UIKit

@objc public class ZZAPQRCodeDetectionRule: NSObject, ZZAPAssetValidationRule {
    
    /// Whether a valid QR code must exist in the image
    private let requireQRCode: Bool
    
    @objc public init(requireQRCode: Bool = true) {
        self.requireQRCode = requireQRCode
    }
    
    public func validate(asset: ZZAPAsset) -> ZZAPAssetValidationFailure? {
        // Only handle image type
        guard asset.mediaType == .image else { return nil }
        
        let semaphore = DispatchSemaphore(value: 0)
        var validationFailure: ZZAPAssetValidationFailure?
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        asset.requestImage(targetSize: CGSize(width: 768, height: 768)) { image in
            defer { semaphore.signal() }
            
            guard let cgImage = image?.cgImage else {
                validationFailure = ZZAPAssetValidationFailure(
                    code: "0x2301",
                    message: ZZAPLocalized("zzap_validation_rule_qrcode_image_unavailable")
                )
                return
            }
            
            let request = VNDetectBarcodesRequest { req, err in
                if let error = err {
                    validationFailure = ZZAPAssetValidationFailure(
                        code: "0x2302",
                        message: ZZAPLocalized("zzap_validation_rule_qrcode_detection_failed"),
                        extra: ["error": error.localizedDescription]
                    )
                    return
                }
                
                let foundQRCode = (req.results as? [VNBarcodeObservation])?.contains(where: {
                    $0.symbology == .QR
                }) ?? false
                
                if self.requireQRCode && !foundQRCode {
                    validationFailure = ZZAPAssetValidationFailure(
                        code: "0x2303",
                        message: ZZAPLocalized("zzap_validation_rule_qrcode_not_found")
                    )
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                validationFailure = ZZAPAssetValidationFailure(
                    code: "0x2304",
                    message: ZZAPLocalized("zzap_validation_rule_qrcode_request_handler_failed"),
                    extra: ["error": error.localizedDescription]
                )
            }
        }
        
        _ = semaphore.wait(timeout: .now() + 60)
        
        return validationFailure
    }
    
}
